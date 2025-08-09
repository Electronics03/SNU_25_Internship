# Adder Tree

The Adder Tree is a hardware structure used in the softmax computation[[1]](#v-references)
$S_j(x) = 2^{x_j^\prime\cdot\log_2e-\log_2(\sum_{i=0}^{N-1}e^{x_i^\prime})}$
to calculate
$\sum_{i=0}^{N-1}e^{x_i^\prime}$.

To efficiently compute the sum value, the design adopts a tree structure.
It is built by combining adder IP modules.
All `out_1` values from the RUs are summed, while `out_0` and the valid signals are forwarded via bypass so that they can be used in the next computation stage.

The design uses a 16-bit fixed-point format in Q6.10 representation.

## I. Functionality

- Input :
    - `valid_in`
    - `in_0_flat`
    - `in_1_flat` : ($\vec{x}$)
- Output :
    - `in_1_sum` ← $\sum_{i=0}^{N-1}\vec{x}$
    - `valid_bypass_out` ← bypass of `valid_in`
    - `in_bypass_flat` ← bypass of `in_0_flat`

## II. Pseudo code

```
function max_tree(valid_in, in_0_flat[N], in_1_flat[N])
{
    STAGE ← log_2(N)

    for j ← 0 to STAGE-1:
        M ← N / (2^(j+1))
        for i ← 0 to M-1:
            add_out ← add_FX16(stage_data [j][2*i], stage_data [j][2*i+1])
            stage_data [j+1][i] ← add_out

    in_1_sum ← stage_data [STAGE][0]

    valid_bypass_out ← valid_in
    in_bypass_flat ← in_0_flat

    return (in_1_sum, valid_bypass_out, in_bypass_flat)
}
```

## III. Architecture

![adder_tree_arch](/Final_Project_Implementation/Explanation/Pictures/add_T_1.png)

Adder IP modules are used for the addition process.
Each Adder IP module has a latency of 2 clock cycles.

Based on the figure above ($8$, $2^3$ inputs), a total of 3 stages of sum operations.
Bypass registers are used to forward the bypass signals.

For 64 inputs, a total of 6 stages are required. With each stage having a latency of 2 clock cycle, the total latency is 12 clock cycles.

## IV. Verilog Code
```verilog
module add_tree #(
    parameter N = 8                  // Number of input elements (must be a power of 2)
)(
    input clk,                       // Clock signal
    input en,                        // Enable signal
    input rst,                       // Synchronous reset

    input valid_in,                  // Valid signal for the input data
    input [N*16-1:0] in_0_flat,      // Flattened N×16-bit bypass data (Q6.10 format)
    input [N*16-1:0] in_1_flat,      // Flattened N×16-bit summation data (Q6.10 format)

    output [15:0] in_1_sum,          // Final sum of all elements from in_1_flat

    output valid_bypass_out,         // Valid signal for bypassed in_0 data
    output [N*16-1:0] in_bypass_flat // Flattened bypassed in_0 data for the next stage
);

    // Number of adder stages in the tree = log2(N)
    localparam STAGE = $clog2(N);

    // Stage-by-stage data wires for the summation tree
    wire [15:0] stage_data [0:STAGE][0:N-1];

    // Pipeline registers for bypassed data and valid signals
    reg [STAGE*2-1:0] reg_valid_bypass;
    reg [N*16-1:0] reg_bypass [0:STAGE*2-1];

    // Pipeline update for bypass signals and valid flags
    integer k;
    always @(posedge clk) begin
        if (rst) begin
            for (k = 0; k <= STAGE*2-1; k = k + 1) begin
                reg_valid_bypass[k] <= 1'b0;
                reg_bypass[k]       <= {N{16'd0}};
            end
        end
        else if (en) begin
            reg_valid_bypass[0] <= valid_in;
            reg_bypass[0]       <= in_0_flat;
            for (k = 0; k <= STAGE*2-2; k = k + 1) begin
                reg_valid_bypass[k+1] <= reg_valid_bypass[k];
                reg_bypass[k+1]       <= reg_bypass[k];
            end
        end
    end

    // Unpack in_1_flat into stage_data[0][i] for the first stage of the adder tree
    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin
            assign stage_data[0][i] = in_1_flat[i*16 +: 16];
        end
    endgenerate

    // Generate comparator tree: at each stage j, compare pairs of values
    generate
        for (j = 0; j < STAGE; j = j + 1) begin : stages
            for (i = 0; i < (N >> (j+1)); i = i + 1) begin : adders
                add_FX16 ADD (
                    .A(stage_data[j][2*i]),
                    .B(stage_data[j][2*i+1]),
                    .CLK(clk),
                    .CE(en),
                    .S(stage_data[j+1][i])
                );
            end
        end
    endgenerate

    // Final sum output from the last stage
    assign in_1_sum = stage_data[STAGE][0];

    // Bypassed original inputs and valid signals
    assign valid_bypass_out = reg_valid_bypass[STAGE*2-1];
    assign in_bypass_flat   = reg_bypass[STAGE*2-1];

endmodule

```

## V. References

[1] Q.-X. Wu, C.-T. Huang, S.-S. Teng, J.-M. Lu, and M.-D. Shieh,  
“A Low-complexity and Reconfigurable Design for Nonlinear Function Approximation in Transformers,”  
in Proc. IEEE International Symposium on Circuits and Systems (ISCAS), 2025.