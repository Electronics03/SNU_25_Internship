# Max Tree

The Max Tree is a hardware structure used in the softmax computation[[1]](#v-references)
$S_j(x) = 2^{x_j^\prime\cdot\log_2e-\log_2(\sum_{i=0}^{N-1}e^{x_i^\prime})}$
to calculate
$x_j^\prime = x_j - \max(\vec{x})$
by finding the maximum value of the input vector.

To efficiently compute the maximum value, the design adopts a tree structure, identical in form to the Adder Tree.
It is built by combining max modules, each of which outputs the larger of two input values.
The `valid_out` signal is asserted only when both inputs are valid.

Since both the maximum value and the original input vector are required for the next operation, bypass signals are also forwarded.
The design uses a 16-bit fixed-point format in Q6.10 representation.

## I. Functionality
### 1. `max_comparator` module
- Input :
    - `valid_A_in`
    - `A_in`
    - `valid_B_in`
    - `B_in`
- Output :
    - `valid_out` ← `valid_A_in` AND `valid_B_in`
    - `MAX_out` ← $\max(A, B)$

### 2. `max_tree` module
- Input :
    - `valid_in`
    - `in_flat` : $\vec{x}$
- Output :
    - `valid_MAX_out` ← `1` when all inputs are valid
    - `MAX` ← $\max(\vec{x})$
    - `valid_bypass_out` ← bypass of `valid_in`
    - `in_bypass` ← bypass of `in_flat` ($\vec{x}$)

## II. Pseudo code
### 1. `max_comparator` module
```
function max_comparator(
    valid_A_in, 
    A_in,
    valid_B_in,
    B_in,
)
{
    valid_out ← AND(valid_A_in, valid_B_in)

    if (A_in > B_in):
        MAX_out ← A_in
    else:
        MAX_out ← B_in

    return (valid_out, MAX_out)
}
```
### 2. `max_tree` module
```
function max_tree(valid_in[N], in_flat[N])
{
    STAGE ← log_2(N)

    for j ← 0 to STAGE-1:
        M ← N / (2^(j+1))
        for i ← 0 to M-1:
            (v_out, max_out) ← max_comparator(
                                   stage_valid[j][2*i],
                                   stage_data[j][2*i],
                                   stage_valid[j][2*i+1],
                                   stage_data[j][2*i+1],
                               )
            stage_valid[j+1][i] ← v_out
            stage_data[j+1][i] ← max_out

    valid_MAX_out ← stage_valid[STAGE][0]
    MAX ← stage_data[STAGE][0]

    valid_bypass_out ← valid_in
    in_bypass ← in_flat

    return (valid_MAX_out, MAX, valid_bypass_out, in_bypass)
}
```

## III. Architecture

![max_tree_arch](/Final_Project_Implementation/Explanation/Pictures/max_T_1.png)

The `max_comparator` module has a latency of 1 clock cycle.

Based on the figure above ($8$, $2^3$ inputs), a total of 3 stages of max operations are required to determine the maximum value.
Bypass registers are used to forward the bypass signals.

For 64 inputs, a total of 6 stages are required. With each stage having a latency of 1 clock cycle, the total latency is 6 clock cycles.

## IV. Verilog Code

### 1. `max_comparator` module
```verilog
module max_comparator (
    input clk,
    input en,
    input rst,

    input valid_A_in,                // Valid for A_in
    input signed [15:0] A_in,        // Signed 16-bit input A (Q6.10)

    input valid_B_in,                // Valid for B_in
    input signed [15:0] B_in,        // Signed 16-bit input B (Q6.10)

    output reg valid_out,            // Output valid: asserted only if both inputs are valid
    output reg signed [15:0] MAX_out // Selected maximum of A_in and B_in
);

    always @(posedge clk) begin
        if (rst) begin
            MAX_out  <= 16'd0;
            valid_out <= 1'b0;
        end 
        else if (en) begin
            MAX_out  <= (A_in > B_in) ? A_in : B_in; // Signed comparison
            valid_out <= valid_A_in & valid_B_in;    // Only valid when both inputs are valid
        end
    end
endmodule
```

### 2. `max_tree` module
```verilog
module max_tree #(
    parameter N = 8                  // Number of inputs (must be power of 2)
)(
    input clk,                       // Clock
    input en,                        // Enable signal
    input rst,                       // Synchronous reset

    input [N-1:0] valid_in,          // Valid signals for each input
    input [N*16-1:0] in_flat,        // Flattened N×16-bit input data (Q6.10 format)

    output valid_MAX_out,            // Valid signal for final MAX output
    output [15:0] MAX,               // Maximum value among all inputs

    output [N-1:0] valid_bypass_out, // Bypassed valid signals for original inputs
    output [N*16-1:0] in_bypass      // Bypassed original input data
);

    // Number of comparison stages in the tree (log2(N))
    localparam STAGE = $clog2(N);

    // Stage-by-stage valid signals and data
    wire [N-1:0] stage_valid [0:STAGE];      // Valid signals for each comparator stage
    wire [15:0] stage_data [0:STAGE][0:N-1]; // Data for each comparator stage

    // Bypass registers to carry original inputs and valid bits through the pipeline
    reg [N-1:0] reg_valid_bypass [0:STAGE-1];
    reg [N*16-1:0] reg_bypass [0:STAGE-1];

    // Pipeline for bypassing original inputs and valid signals
    integer k;
    always @(posedge clk) begin
        if (rst) begin
            for (k = 0; k <= STAGE-1; k = k + 1) begin
                reg_valid_bypass[k] <= {N{1'b0}};
                reg_bypass[k] <= {N{16'd0}};
            end
        end
        else if (en) begin
            reg_valid_bypass[0] <= valid_in;
            reg_bypass[0] <= in_flat;
            for (k = 0; k <= STAGE-2; k = k + 1) begin
                reg_valid_bypass[k+1] <= reg_valid_bypass[k];
                reg_bypass[k+1] <= reg_bypass[k];
            end
        end
    end

    // Initialize stage 0 valid signals
    assign stage_valid[0] = valid_in;

    // Unpack flattened inputs into stage_data[0][i]
    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin
            assign stage_data[0][i] = in_flat[i*16 +: 16];
        end
    endgenerate

    // Generate comparator tree: at each stage j, compare pairs of values
    generate
        for (j = 0; j < STAGE; j = j + 1) begin : stages
            for (i = 0; i < (N >> (j+1)); i = i + 1) begin : comps
                max_comparator MAX(
                    .clk(clk),
                    .en(en),
                    .rst(rst),

                    .valid_A_in(stage_valid[j][2*i]),
                    .A_in(stage_data[j][2*i]),

                    .valid_B_in(stage_valid[j][2*i+1]),
                    .B_in(stage_data[j][2*i+1]),

                    .valid_out(stage_valid[j+1][i]),
                    .MAX_out(stage_data[j+1][i])
                );
            end
        end
    endgenerate

    // Final outputs: MAX value and its valid signal
    assign valid_MAX_out = stage_valid[STAGE][0];
    assign MAX = stage_data[STAGE][0];

    // Bypassed original inputs and valid signals
    assign valid_bypass_out = reg_valid_bypass[STAGE-1];
    assign in_bypass = reg_bypass[STAGE-1];

endmodule
```

## V. References

[1] Q.-X. Wu, C.-T. Huang, S.-S. Teng, J.-M. Lu, and M.-D. Shieh,  
“A Low-complexity and Reconfigurable Design for Nonlinear Function Approximation in Transformers,”  
in Proc. IEEE International Symposium on Circuits and Systems (ISCAS), 2025.