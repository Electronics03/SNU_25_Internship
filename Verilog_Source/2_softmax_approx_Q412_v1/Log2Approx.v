/*
16-bit fixed-point : Q4.12
Input  : in_x  (16-bit unsigned)
Output : log2_x (16-bit unsigned)
Description:
Approximates log2(x) by detecting the leading '1' position (integer part)
and extracting fractional bits via shift normalization.
*/

module log2_approx(
    input ready,
    input [15:0] in_x,
    input clk,
    input rst,
    input en,
    output [15:0] log2_x,
    output [15:0] out_x,
    output valid
);
    reg [3:0] count_s1;
    reg [3:0] int_part_s1;

    wire [3:0] count_s2;
    wire [3:0] int_part_s2;
    wire [15:0] in_x_s2;

    wire [15:0] frac_part;

    reg [15:0] reg_0;
    reg [23:0] reg_1;
    reg [31:0] reg_2;

    reg prop_0;
    reg prop_1;
    reg prop_2;

    always @(posedge clk) begin
        if (rst) begin
            reg_0 <= 16'd0;
            prop_0 <= 1'b0;
            reg_1 <= 24'd0;
            prop_1 <= 1'b0;
            reg_2 <= 32'd0;
            prop_2 <= 1'b0;
        end
        else if (en) begin
            reg_0 <= in_x;
            prop_0 <= ready;
            reg_1 <= {count_s1, int_part_s1, reg_0};
            prop_1 <= prop_0;
            reg_2 <= {in_x_s2, int_part_s2, frac_part[14:3]};
            prop_2 <= prop_1;
        end
    end

    assign count_s2 = reg_1[23:20];
    assign int_part_s2 = reg_1[19:16];
    assign in_x_s2 = reg_1[15:0];

    always @(*) begin
        casex (reg_0)
            16'b1xxx_xxxx_xxxx_xxxx: begin count_s1 = 4'd0;  int_part_s1 = 4'b0011; end
            16'b01xx_xxxx_xxxx_xxxx: begin count_s1 = 4'd1;  int_part_s1 = 4'b0010; end
            16'b001x_xxxx_xxxx_xxxx: begin count_s1 = 4'd2;  int_part_s1 = 4'b0001; end
            16'b0001_xxxx_xxxx_xxxx: begin count_s1 = 4'd3;  int_part_s1 = 4'b0000; end
            16'b0000_1xxx_xxxx_xxxx: begin count_s1 = 4'd4;  int_part_s1 = 4'b1111; end
            16'b0000_01xx_xxxx_xxxx: begin count_s1 = 4'd5;  int_part_s1 = 4'b1110; end
            16'b0000_001x_xxxx_xxxx: begin count_s1 = 4'd6;  int_part_s1 = 4'b1101; end
            16'b0000_0001_xxxx_xxxx: begin count_s1 = 4'd7;  int_part_s1 = 4'b1100; end
            16'b0000_0000_1xxx_xxxx: begin count_s1 = 4'd8;  int_part_s1 = 4'b1011; end
            16'b0000_0000_01xx_xxxx: begin count_s1 = 4'd9;  int_part_s1 = 4'b1010; end
            16'b0000_0000_001x_xxxx: begin count_s1 = 4'd10; int_part_s1 = 4'b1001; end
            16'b0000_0000_0001_xxxx: begin count_s1 = 4'd11; int_part_s1 = 4'b1000; end
            16'b0000_0000_0000_1xxx: begin count_s1 = 4'd12; int_part_s1 = 4'b0111; end
            16'b0000_0000_0000_01xx: begin count_s1 = 4'd13; int_part_s1 = 4'b0110; end
            16'b0000_0000_0000_001x: begin count_s1 = 4'd14; int_part_s1 = 4'b0101; end
            16'b0000_0000_0000_0001: begin count_s1 = 4'd15; int_part_s1 = 4'b0100; end
        endcase
    end

    assign frac_part = in_x_s2 << count_s2;
    assign log2_x = reg_2[15:0];
    assign out_x = reg_2[31:16];
    assign valid = prop_2;

endmodule
