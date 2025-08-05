# Reconfigurable Unit (RU)

The Reconfigurable Unit (RU) is the most essential module in the softmax approximation model proposed in [[1]](#v-references).
The softmax approximation process can be divided into two key stages.

First, it computes $x_j^\prime \cdot \log_2 e$ and then performs the $2^x$ operation to obtain $e^{x_j^\prime}$.

Next, it calculates $\log_2(\sum_{i=0}^{N-1} e^{x_i^\prime})$ and finally evaluates
$2^{x_j^\prime \cdot \log_2 e - \log_2(\sum_{i=0}^{N-1} e^{x_i^\prime})}$ to produce the softmax approximation result.

At each stage, the RU performs the required operation by changing its select signals accordingly.
The architecture introduced in [[1]](#v-references) is shown below.

![RU_3](/Final_Project_Implementation/Explanation/Pictures/RU_3.png)

The design uses a 16-bit fixed-point format in Q6.10 representation.

## I. Functionality
### 1. `[sel_mux, sel_mult] = [1, 1]`
- Input :
    - `in_0`
    - `in_1`
- Output :
    - `out_0` ← $(\mathrm{in_1 - in_0})\cdot\log_2e$
    - `out_1` ← $e^{(\mathrm{in_1 - in_0})}$

### 2. `[sel_mux, sel_mult] = [0, 0]`
- Input :
    - `in_0`
    - `in_1`
- Output :
    - `out_0` ← $(\mathrm{in_1} - \log_2(\mathrm{in_0}))$
    - `out_1` ← $2^{(\mathrm{in_1 - \log_2(\mathrm{in_0})})}$

## II. Operation Flow

1. **Logarithmic Approximation (`stage1_log2_approx`)**

    The `stage1_log2_approx` module computes the base-2 logarithm of `in_0` and forwards both `in_0` and `in_1` via bypass signals.
    The output `log_in_0` is a 16-bit fixed-point approximation of $\log_2(\mathrm{in_0})$.

2. **Subtraction via MUX Selection**

    Using the `sel_mux` signal, the RU selects either `in_0` or `log_in_0` as the value to be subtracted - this selected input is referred to as `sub`.
    The subtraction is then performed as `in_1 - sub`.

3. **Multiplication via MUX Selection**

    Using the `sel_mult` signal, the RU selects a constant multiplier - this selected constant is referred to as `mult`.
    The result of the subtraction is then multiplied by `mult`.

4. **Exponential Approximation (`stage3_pow2_approx`)**

    The multiplication output is passed to `stage3_pow2_approx` as `in_x`, where the base-2 exponential $2^x$ is approximated.
    The module outputs both `pow_in_x`, the 16-bit fixed-point result, and a bypassed version of `in_x` for further downstream use.

### Pseudo Code
```
function softmax_approx(in_0, in_1, sel_mux, sel_mult)
{
    log_in_0 ← log2_approx(in_0)

    if (sel_mux == 1):
        sub ← in_0
    else:
        sub ← log_in_0

    diff ← (in_1 - sub)

    if (sel_mult == 1):
        mult ← 1.4427
    else:
        mult ← 1

    mult_result ← (diff * mult)
    pow_in_x ← pow2_approx(mult_result)

    out_0 ← mult_result
    out_1 ← pow_in_x

    return out_0, out_1
}
```

## III. Architecture

![RU_6](/Final_Project_Implementation/Explanation/Pictures/RU_6.png)

The design is implemented using three stages.
The approximation operations in Stage 1 and Stage 3 are implemented as each modules.
The SUB and MULT operations are performed using integer arithmetic IPs.
The SUB operation has a latency of 2 cycles, and the MULT operation has a latency of 4 cycles.
To maintain signal validity, a pipeline register is added to propagate the valid signal across the 6-cycle delay.
In total, the design incurs a latency of 3 (Stage 1) + 2 (SUB) + 4 (MULT) + 2 (Stage 3) = 11 cycles.

## IV. Verilog Code
### IP
| Instance Name | IP name | VLNV | Description | Latency |
|---------------|---------|------|-------------|---------|
| `sub_FX16` | Adder/Subtracter | `xilinx.com:ip:c_addsub:12` | 16-bit fixed-point subtractor (Q6.10) | 2 |
| `mult_FX16` | Multiplier | `xilinx.com:ip:mult_gen:12` | 16×16-bit fixed-point multiplier (Q6.10) | 4 |

### Code
```verilog
module RU (
    input clk,
    input en,
    input rst,

    input sel_mult,      // Select signal for multiplier constant
    input sel_mux,       // Select signal for subtraction operand

    input valid_in,      // Input valid signal
    input [15:0] in_0,   // First input operand
    input [15:0] in_1,   // Second input operand

    output valid_out,    // Output valid signal
    output [15:0] out_0, // Bypassed in_x (from stage3_pow2_approx)
    output [15:0] out_1  // Final output: 2^x approximation result
);

    // Wires for stage1_log2_approx output
    wire [15:0] log_in_0;    // Approximation of log2(in_0)
    wire [15:0] in_0_bypass; // Bypass of in_0
    wire [15:0] in_1_bypass; // Bypass of in_1

    // Wires for MUX selection
    wire [15:0] sub;         // Selected value to subtract from in_1
    wire [15:0] mult;        // Selected multiplier constant

    // Wires for intermediate arithmetic
    wire [15:0] diff;        // Result of subtraction
    wire [31:0] mult_result; // Result of multiplication
    wire [15:0] out_x;       // Final input to pow2 approximation

    // Valid pipeline for 6-cycle delay compensation (2 for sub + 4 for mult)
    wire valid_log;
    reg [5:0] valid_pipe;

    // Pipeline register to propagate valid signal through arithmetic stages
    always @(posedge clk) begin
        if (rst) begin
            valid_pipe[0] <= 1'b0;
            valid_pipe[[1]](#v-references) <= 1'b0;
            valid_pipe[2] <= 1'b0;
            valid_pipe[3] <= 1'b0;
            valid_pipe[4] <= 1'b0;
            valid_pipe[5] <= 1'b0;
        end
        else if (en) begin
            valid_pipe[0] <= valid_log;
            valid_pipe[[1]](#v-references) <= valid_pipe[0];
            valid_pipe[2] <= valid_pipe[[1]](#v-references);
            valid_pipe[3] <= valid_pipe[2];
            valid_pipe[4] <= valid_pipe[3];
            valid_pipe[5] <= valid_pipe[4];
        end
    end

    // Select multiplier constant (Q6.10 fixed-point)
    assign mult = (sel_mult) ? 16'b0000_0101_1100_0100 : 16'b0000_0100_0000_0000;

    // Select subtraction operand: in_0 or log_in_0
    assign sub = (sel_mux) ? in_0_bypass : log_in_0;

    // Subtraction: in_1 - sub
    sub_FX16 SUB(
        .A(in_1_bypass),
        .B(sub),
        .CLK(clk),
        .CE(en),
        .S(diff)
    );

    // Multiplication: diff × mult
    mult_FX16 MULT(
        .CLK(clk),
        .A(diff),
        .B(mult),
        .CE(en),
        .P(mult_result)
    );

    // Stage 1: Logarithmic approximation
    stage1_log2_approx STAGE1 (
        .clk(clk),
        .en(en),
        .rst(rst),

        .valid_in(valid_in),
        .in_0(in_0),
        .in_1(in_1),

        .valid_out(valid_log),
        .log_in_0(log_in_0),

        .in_0_bypass(in_0_bypass),
        .in_1_bypass(in_1_bypass)
    );

    // Stage 3: Exponential approximation
    stage3_pow2_approx STAGE2 (
        .clk(clk),
        .en(en),
        .rst(rst),

        .valid_in(valid_pipe[5]),
        .in_x(mult_result[25:10]),

        .valid_out(valid_out),
        .pow_in_x(out_1),
        .in_x_bypass(out_0)
    );

endmodule
```
## V. References

[1] Q.-X. Wu, C.-T. Huang, S.-S. Teng, J.-M. Lu, and M.-D. Shieh,  
“A Low-complexity and Reconfigurable Design for Nonlinear Function Approximation in Transformers,”  
in Proc. IEEE International Symposium on Circuits and Systems (ISCAS), 2025.