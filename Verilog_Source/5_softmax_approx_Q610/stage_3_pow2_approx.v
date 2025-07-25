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
    reg [21:0] reg_stg_0;
    reg [32:0] reg_stg_1;

    wire [9:0] in_x_frac;
    wire [5:0] in_x_int;

    reg [4:0] shift;
    wire [15:0] result;

    assign in_x_frac = reg_stg_0[9:0];
    assign in_x_int = in_x[14:10];

    always @(posedge clk) begin
        if (rst) begin
            reg_stg_0 <= 22'd0;
            reg_stg_1 <= 33'd0;
        end
        else if (en) begin
            reg_stg_0 <= {valid_in, shift, in_x};
            reg_stg_1 <= {reg_stg_0[21], result, reg_stg_0[15:0]};
        end
    end

    always @(*) begin
        case (in_x_int)
            5'b10110: shift = 5'd15;
            5'b10111: shift = 5'd14;
            5'b11000: shift = 5'd13;
            5'b11001: shift = 5'd12;
            5'b11010: shift = 5'd11;
            5'b11011: shift = 5'd10;
            5'b11100: shift = 5'd9;
            5'b11101: shift = 5'd8;
            5'b11110: shift = 5'd7;
            5'b11111: shift = 5'd6;
            5'b00000: shift = 5'd5;
            5'b00001: shift = 5'd4;
            5'b00010: shift = 5'd3;
            5'b00011: shift = 5'd2;
            5'b00100: shift = 5'd1;
            5'b00101: shift = 5'd0;
            default: shift = 5'd16;
        endcase
    end

    assign result = {1'b1, in_x_frac, 5'b0_0000} >> reg_stg_0[20:16];

    assign valid_out = reg_stg_1[32];
    assign pow_in_x = reg_stg_1[31:16];
    assign in_x_bypass = reg_stg_1[15:0];

endmodule