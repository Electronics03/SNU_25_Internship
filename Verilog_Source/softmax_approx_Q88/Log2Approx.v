/*
16-bit fixed-point : Q4.12
stage1_log2_approx module
Description:
- Approximates log2(x) using leading-one detection for the integer part.
- Computes fractional part via shift normalization based on leading-one position.
- Implements a 3-stage pipeline to register inputs, intermediate values, and outputs.
- Passes through original inputs for alignment in pipelined architectures.
- Outputs 16-bit fixed-point approximation of log2, along with valid and bypass signals.
*/

module stage1_log2_approx(
    input valid_in,
    input clk,
    input rst,
    input en,
    input [15:0] in_0,
    input [15:0] in_1,
    output valid_out,
    output [15:0] log_in_0,
    output [15:0] in_0_bypass,
    output [15:0] in_1_bypass
);

    reg [32:0] reg_0;
    reg [40:0] reg_1;
    reg [48:0] reg_2;

    reg [3:0] count;
    reg [3:0] int_part;

    wire [15:0] frac_part;

    always @(posedge clk) begin
        if (rst) begin
            reg_0 <= 33'd0;
            reg_1 <= 41'd0;
            reg_2 <= 49'd0;
        end
        else if (en) begin
            reg_0 <= {valid_in, in_1, in_0};
            reg_1 <= {reg_0[32], int_part, count, reg_0[31:0]};
            reg_2 <= {reg_1[40:36], frac_part[14:3] ,reg_1[31:0]};
        end
    end

    assign frac_part = reg_1[15:0] << reg_1[35:32];

    always @(*) begin
        casex (reg_0[15:0])
            16'b1xxx_xxxx_xxxx_xxxx: begin count = 4'd0; int_part = 4'b0011; end
            16'b01xx_xxxx_xxxx_xxxx: begin count = 4'd1; int_part = 4'b0010; end
            16'b001x_xxxx_xxxx_xxxx: begin count = 4'd2; int_part = 4'b0001; end
            16'b0001_xxxx_xxxx_xxxx: begin count = 4'd3; int_part = 4'b0000; end
            16'b0000_1xxx_xxxx_xxxx: begin count = 4'd4; int_part = 4'b1111; end
            16'b0000_01xx_xxxx_xxxx: begin count = 4'd5; int_part = 4'b1110; end
            16'b0000_001x_xxxx_xxxx: begin count = 4'd6; int_part = 4'b1101; end
            16'b0000_0001_xxxx_xxxx: begin count = 4'd7; int_part = 4'b1100; end
            16'b0000_0000_1xxx_xxxx: begin count = 4'd8; int_part = 4'b1011; end
            16'b0000_0000_01xx_xxxx: begin count = 4'd9; int_part = 4'b1010; end
            16'b0000_0000_001x_xxxx: begin count = 4'd10; int_part = 4'b1001; end
            16'b0000_0000_0001_xxxx: begin count = 4'd11; int_part = 4'b1000; end
            16'b0000_0000_0000_1xxx: begin count = 4'd12; int_part = 4'b0111; end
            16'b0000_0000_0000_01xx: begin count = 4'd13; int_part = 4'b0110; end
            16'b0000_0000_0000_001x: begin count = 4'd14; int_part = 4'b0101; end
            16'b0000_0000_0000_0001: begin count = 4'd15; int_part = 4'b0100; end
        endcase
    end

    assign valid_out = reg_2[48];
    assign log_in_0 = reg_2[47:32];
    assign in_1_bypass = reg_2[31:16];
    assign in_0_bypass = reg_2[15:0];
endmodule