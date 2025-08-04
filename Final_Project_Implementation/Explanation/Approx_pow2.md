# Stage3 $2^x$ approximation

The approximation method for $2^x$ is introduced in [[1]](#v-references).
Based on this, I present a Verilog implementation of a 2-stage pipelined unit that computes an approximate result of $2^x$. The design uses a 16-bit fixed-point format in Q6.10 representation.

## I. Approximation Formula

$$
\begin{aligned}
2^x &= 2^{\mathrm{int}(x) + \mathrm{frac}(x)}\\
&= 2^\mathrm{int}(x) \cdot 2^\mathrm{frac}(x)\\
\therefore &\approx (1+\mathrm{frac}(x)) \ll \mathrm{int}(x)
\end{aligned}
$$

The function $2^x$ can be approximated using the formula shown above.
This approximation looks like a interpolation based on integer points when shown in a graph.
By using only shift and addition operations to find $2^x$, I can estimate the value of $2^x$ efficiently.

![pow2_approx](/Final_Project_Implementation/Explanation/Pictures/stage3_pow2_approx_2.png)

## II. Operation Flow

To compute $2^x$, I use the formula [shown above](#i-approximation-formula).

1. Determine the shift amount

    The shift amount is determined based on the integer part of the input.  
    The mapping between the integer part and the shift amount follows the table below:  
    ![pow2_approx_table](/Final_Project_Implementation/Explanation/Pictures/stage3_pow2_approx_4.png)  
    This is implemented using a `case` statement in Verilog, which is synthesized as a LUT.

2. Compute $2^x$

    The fractional part is right-shifted by the amount determined in Step 1.  
    The result is a 16-bit approximation of $2^x$.

### Pseudo Code
```
function pow2_approx(input x)
{
    int_part ← x[15:10]
    frac_part ← x[9:0]

    shift_amt ← lookup_shift(int_part)
    norm_val ← {1'b1, frac_part, 5'b0}
    
    result ← norm_val >> shift_amt

    return result
}
```

## III. Architecture

![log2_approx](/Final_Project_Implementation/Explanation/Pictures/stage3_pow2_approx_3.png)

The operation flow is divided into two stages for computation.  
Since the Reconfigurable Unit (RU) directly uses `in_x` to compute `out_0`, they are forwarded via bypass signals.  
To ensure the validity of the computation, the `valid_in` signal is propagated as `valid_out`.

## IV. Verilog Code

```verilog
module stage3_pow2_approx(
    input clk,
    input en,
    input rst,

    input valid_in,
    input [15:0] in_x,

    output valid_out,
    output [15:0] pow_in_x,
    output [15:0] in_x_bypass
);
    // Pipeline registers for 2 stages
    reg [21:0] reg_stg_0; // Stage 0: {valid, shift, in_x}
    reg [32:0] reg_stg_1; // Stage 1: {valid, result, in_x}

    wire [9:0] in_x_frac; // Fractional part (lower 10 bits)
    wire [5:0] in_x_int;  // Integer part (upper 6 bits)

    reg [4:0] shift;      // Right shift amount determined by int_part
    wire [15:0] result;   // Final 2^x approximation result

    assign in_x_frac = reg_stg_0[9:0];
    assign in_x_int = in_x[15:10];

    // Pipeline update
    always @(posedge clk) begin
        if (rst) begin
            reg_stg_0 <= 22'd0;
            reg_stg_1 <= 33'd0;
        end
        else if (en) begin
            // Stage 0: input capture and shift assignment
            reg_stg_0 <= {valid_in, shift, in_x};
            // Stage 1: compute result and forward original input
            reg_stg_1 <= {reg_stg_0[21], result, reg_stg_0[15:0]};
        end
    end

    // Stage 0: determine shift amount from integer part (int_part)
    always @(*) begin
        case (in_x_int)
            6'b110110: shift = 5'd15;
            6'b110111: shift = 5'd14;
            6'b111000: shift = 5'd13;
            6'b111001: shift = 5'd12;
            6'b111010: shift = 5'd11;
            6'b111011: shift = 5'd10;
            6'b111100: shift = 5'd9;
            6'b111101: shift = 5'd8;
            6'b111110: shift = 5'd7;
            6'b111111: shift = 5'd6;
            6'b000000: shift = 5'd5;
            6'b000001: shift = 5'd4;
            6'b000010: shift = 5'd3;
            6'b000011: shift = 5'd2;
            6'b000100: shift = 5'd1;
            6'b000101: shift = 5'd0;
            default:   shift = 5'd16; // Undefined behavior fallback
        endcase
    end

    // Stage 1: apply right shift to compute 2^x approximation
    assign result = {1'b1, in_x_frac, 5'b00000} >> reg_stg_0[20:16];
    // Output stage
    assign valid_out = reg_stg_1[32];
    assign pow_in_x = reg_stg_1[31:16];
    // Bypass original input
    assign in_x_bypass = reg_stg_1[15:0];

endmodule
```

## V. References

[1] Q.-X. Wu, C.-T. Huang, S.-S. Teng, J.-M. Lu, and M.-D. Shieh,  
“A Low-complexity and Reconfigurable Design for Nonlinear Function Approximation in Transformers,”  
in Proc. IEEE International Symposium on Circuits and Systems (ISCAS), 2025.