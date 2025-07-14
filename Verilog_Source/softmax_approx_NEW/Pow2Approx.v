/*
16-bit fixed-point : Q4.12
Input  : in_x  (16-bit signed)
Output : pow2_x (16-bit signed)
Description:
Approximates 2^x using integer and fractional decomposition.
- Integer part controls left/right shift (scaling by 2^int_part).
- Fractional part approximated as (1 + frac) for 2^frac ≈ 1 + frac.
Implements 2^x ≈ 2^int_part * (1 + frac) using simple shift and add.
*/

module pow2_approx(
    input ready,
    input [15:0] in_x,
    input clk,
    input rst,
    input en,
    output [15:0] pow2_x,
    output [15:0] out_x,
    output valid
);

    reg [15:0] reg_0;
    reg [19:0] reg_1;
    reg [31:0] reg_2;

    reg prop_0;
    reg prop_1;
    reg prop_2;

    wire [3:0] abs_s1;
    wire [15:0] mult_result;

    always @(posedge clk) begin
        if (rst) begin
            reg_0 <= 16'd0;
            prop_0 <= 1'b0;
            reg_1 <= 17'd0;
            prop_1 <= 1'b0;
            reg_2 <= 16'd0;
            prop_2 <= 1'b0;
        end
        else if (en) begin
            reg_0 <= in_x;
            prop_0 <= ready;
            reg_1 <= {abs_s1, reg_0};
            prop_1 <= prop_0;
            reg_2 <= {reg_1[15:0], mult_result};
            prop_2 <= prop_1;
        end
    end

    abs_4 ABS(
        .num(reg_0[15:12]),
        .abs_num(abs_s1)
    );

    wire sign;
    assign sign = reg_1[15];

    wire [15:0] one_plus_frac;
    assign one_plus_frac = {4'b0001, reg_1[11:0]};

    assign mult_result = (sign) ? (one_plus_frac >> reg_1[19:16]) : (one_plus_frac << reg_1[19:16]);

    assign pow2_x = reg_2[15:0];
    assign out_x = reg_2[31:16];
    assign valid = prop_2;
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