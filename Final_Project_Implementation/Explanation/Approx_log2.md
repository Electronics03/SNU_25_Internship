# Stage1 $\log_2x$ approximation

The approximation method for $\log_2x$ is introduced in [[1]](#v-references).
Based on this, I present a Verilog implementation of a 3-stage pipelined unit that computes an approximate result of $\log_2x$. The design uses a 16-bit fixed-point format in Q6.10 representation.

## I. Approximation Formula

$$
\begin{aligned}
\log_2x &= \log_2(2^w\cdot x^\prime)\\
&= w\cdot\log_2x^\prime\\
\therefore &\approx w+x^\prime-1\\
\end{aligned}
$$

$$
\begin{aligned}
x &= 2^w \cdot \frac{x}{2^w} = 2^w \cdot x^\prime &(1 \le x^\prime < 2)\\
\end{aligned}
$$

The function $\log_2x$ can be approximated using the formula shown above.
This approximation looks like a interpolation based on integer points when shown in a graph.
By using only shift and addition operations to find $w$ and $x'$ (the integer and fractional parts), I can estimate the value of $\log_2x$ efficiently.

![log2_approx](/Final_Project_Implementation/Explanation/Pictures/stage1_log2_approx_2.png)

## II. Operation Flow

To compute $\log_2x$, I use the formula [shown above](#i-approximation-formula).

1. **Leading-One Detection**

    First, the position of the first 1 in the input is detected.
    This position is denoted as `count`, representing how many bits the input needs to be shifted.
    In Verilog, this is implemented using a `casex` statement, which is synthesized as a LUT.

2. **Normalization and Fraction Extraction**

    Next, the input is left-shifted by `count` so that the leading 1 moves to the MSB (bit [15]).
    The leading 1 is then discarded, and the following 10 bits (bits [14:5]) are extracted as the fractional part.

3. **Integer Part Calculation**

    Simultaneously, the integer part is calculated by subtracting `5` from `count`, multiplying the result by `-1`, and converting it into a 6-bit two’s complement number.
    This is implemented using a `case` statement in Verilog, which is synthesized as a LUT.

4. **Final Approximation**

    Finally, the integer part and the fractional part are concatenated to form the 16-bit approximation of $\log_2 x$.

### Pseudo Code
```
function log2_approx(input x)
{
    count ← position of most significant '1' bit in x

    norm_x ← x << count
    frac_part ← bits of norm_x[14:5]
    int_part ← (count - 5) * (-1)

    log2x ← {int_part[5:0], frac_part[9:0]}
    return log2x
}
```

## III. Architecture

![log2_approx](/Final_Project_Implementation/Explanation/Pictures/stage1_log2_approx_3.png)

The operation flow is divided into three stages for computation.
Since the Reconfigurable Unit (RU) directly uses `in_0` and `in_1`, they are forwarded via bypass signals.
To ensure the validity of the computation, the `valid_in` signal is propagated as `valid_out`.

## IV. Verilog Code

```verilog
module stage1_log2_approx(
    input clk,
    input en,
    input rst,

    input valid_in,
    input [15:0] in_0,
    input [15:0] in_1,

    output valid_out,
    output [15:0] log_in_0,

    output [15:0] in_0_bypass,
    output [15:0] in_1_bypass
);
    // Pipeline registers for 3 stages
    reg [32:0] reg_stg_0;  // Stage 0: {valid, in_1, in_0}
    reg [36:0] reg_stg_1;  // Stage 1: {valid, count, in_1, in_0}
    reg [48:0] reg_stg_2;  // Stage 2: {valid, result, in_1, in_0}

    reg [3:0] count;       // Leading-one position
    reg [5:0] int_part;    // Integer part of log2 result

    wire [15:0] frac_part; // Fractional part of log2 result
    wire [15:0] result;    // Final log2 approximation result

    // Pipeline update
    always @(posedge clk) begin
        if (rst) begin
            reg_stg_0 <= 33'd0;
            reg_stg_1 <= 37'd0;
            reg_stg_2 <= 49'd0;
        end
        else if (en) begin
            // Stage 0: input capture
            reg_stg_0 <= {valid_in, in_1, in_0};
            // Stage 1: shift count and input forwarding
            reg_stg_1 <= {reg_stg_0[32], count, reg_stg_0[31:0]};
            // Stage 2: final result and bypass
            reg_stg_2 <= {reg_stg_1[36], result, reg_stg_1[31:0]};
        end
    end

    // Stage 0: leading-one detection
    always @(*) begin
        casex (reg_stg_0[15:0])
            16'b1xxx_xxxx_xxxx_xxxx: count = 4'b0000;
            16'b01xx_xxxx_xxxx_xxxx: count = 4'b0001;
            16'b001x_xxxx_xxxx_xxxx: count = 4'b0010;
            16'b0001_xxxx_xxxx_xxxx: count = 4'b0011;
            16'b0000_1xxx_xxxx_xxxx: count = 4'b0100;
            16'b0000_01xx_xxxx_xxxx: count = 4'b0101;
            16'b0000_001x_xxxx_xxxx: count = 4'b0110;
            16'b0000_0001_xxxx_xxxx: count = 4'b0111;
            16'b0000_0000_1xxx_xxxx: count = 4'b1000;
            16'b0000_0000_01xx_xxxx: count = 4'b1001;
            16'b0000_0000_001x_xxxx: count = 4'b1010;
            16'b0000_0000_0001_xxxx: count = 4'b1011;
            16'b0000_0000_0000_1xxx: count = 4'b1100;
            16'b0000_0000_0000_01xx: count = 4'b1101;
            16'b0000_0000_0000_001x: count = 4'b1110;
            16'b0000_0000_0000_0001: count = 4'b1111;
        endcase
    end

    // Stage 1: compute integer part from count
    always @(*) begin
        case (reg_stg_1[35:32])
            4'b0000: int_part = 6'b00_0101;
            4'b0001: int_part = 6'b00_0100;
            4'b0010: int_part = 6'b00_0011;
            4'b0011: int_part = 6'b00_0010;
            4'b0100: int_part = 6'b00_0001;
            4'b0101: int_part = 6'b00_0000;
            4'b0110: int_part = 6'b11_1111;
            4'b0111: int_part = 6'b11_1110;
            4'b1000: int_part = 6'b11_1101;
            4'b1001: int_part = 6'b11_1100;
            4'b1010: int_part = 6'b11_1011;
            4'b1011: int_part = 6'b11_1010;
            4'b1100: int_part = 6'b11_1001;
            4'b1101: int_part = 6'b11_1000;
            4'b1110: int_part = 6'b11_0111;
            4'b1111: int_part = 6'b11_0110;
        endcase
    end

    // Stage 1: extract fractional bits by normalization (shift)
    assign frac_part = reg_stg_1[15:0] << reg_stg_1[35:32];

    // Combine integer and fractional part
    assign result = {int_part, frac_part[14:5]};

    // Stage 2: outputs
    assign valid_out = reg_stg_2[48];
    assign log_in_0 = reg_stg_2[47:32];

    // Bypass
    assign in_1_bypass = reg_stg_2[31:16];
    assign in_0_bypass = reg_stg_2[15:0];
endmodule
```

## V. References

[1] Q.-X. Wu, C.-T. Huang, S.-S. Teng, J.-M. Lu, and M.-D. Shieh,  
“A Low-complexity and Reconfigurable Design for Nonlinear Function Approximation in Transformers,”  
in Proc. IEEE International Symposium on Circuits and Systems (ISCAS), 2025.