/*
16-bit fixed-point : Q4.12
stage3_pow2_approx module
Description:
- Approximates 2^x for a 16-bit fixed-point input using pipeline stages.
- Computes exponentiation via integer and fractional separation.
- Uses abs_4 module to obtain absolute value of integer exponent bits.
- Performs left or right shift on (1 + fractional) part depending on sign.
- Includes 3 pipeline registers for staged processing of input and intermediate values.
- Outputs 16-bit fixed-point result approximating 2^x, along with bypassed input and valid signal.
*/

module stage3_pow2_approx(
    input valid_in,
    input clk,
    input rst,
    input en,
    input [15:0] in_x,
    output valid_out,
    output [15:0] pow_in_x,
    output [15:0] in_x_bypass
);
    reg [16:0] reg_0;
    reg [20:0] reg_1;
    reg [32:0] reg_2;

    wire [3:0] abs_num;

    wire sign;
    assign sign = reg_1[15];

    wire [15:0] one_plus_frac;
    assign one_plus_frac = {4'b0001, reg_1[11:0]};

    wire [15:0] mult_result;
    assign mult_result = (sign) ? (one_plus_frac >> reg_1[19:16]) : (one_plus_frac << reg_1[19:16]);

    abs_4 ABS(
        .num(reg_0[15:12]),
        .abs_num(abs_num)
    );

    always @(posedge clk) begin
        if (rst) begin
            reg_0 <= 17'd0;
            reg_1 <= 21'd0;
            reg_2 <= 33'd0;
        end
        else if (en) begin
            reg_0 <= {valid_in, in_x};
            reg_1 <= {reg_0[16], abs_num, reg_0[15:0]};
            reg_2 <= {reg_1[20], mult_result, reg_1[15:0]};
        end
    end

    assign valid_out = reg_2[32];
    assign pow_in_x = reg_2[31:16];
    assign in_x_bypass = reg_2[15:0];

endmodule


module abs_4 (
    input [3:0] num,
    output reg [3:0] abs_num
);
    always @(*) begin
        case (num)
            4'b1000: abs_num = 4'b1000;
            4'b1001: abs_num = 4'b0111;
            4'b1010: abs_num = 4'b0110;
            4'b1011: abs_num = 4'b0101;
            4'b1100: abs_num = 4'b0100;
            4'b1101: abs_num = 4'b0011;
            4'b1110: abs_num = 4'b0010;
            4'b1111: abs_num = 4'b0001;
            4'b0000: abs_num = num;
            4'b0001: abs_num = num;
            4'b0010: abs_num = num;
            4'b0011: abs_num = num;
            4'b0100: abs_num = num;
            4'b0101: abs_num = num;
            4'b0110: abs_num = num;
            4'b0111: abs_num = num;
        endcase
    end
endmodule