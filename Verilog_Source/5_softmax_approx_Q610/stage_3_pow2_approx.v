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
    reg [20:0] reg_stg_0;
    reg [32:0] reg_stg_1;

    wire [9:0] in_x_frac;
    wire [5:0] in_x_int;

    reg [3:0] shift;
    wire [15:0] result;

    assign in_x_frac = reg_stg_0[9:0];
    assign in_x_int = in_x[13:10];

    always @(posedge clk) begin
        if (rst) begin
            reg_stg_0 <= 21'd0;
            reg_stg_1 <= 33'd0;
        end
        else if (en) begin
            reg_stg_0 <= {valid_in, shift, in_x};
            reg_stg_1 <= {reg_stg_0[20], result, reg_stg_0[15:0]};
        end
    end

    always @(*) begin
        case (in_x_int)
            4'b0110: shift = 4'd15;
            4'b0111: shift = 4'd14;
            4'b1000: shift = 4'd13;
            4'b1001: shift = 4'd12;
            4'b1010: shift = 4'd11;
            4'b1011: shift = 4'd10;
            4'b1100: shift = 4'd9;
            4'b1101: shift = 4'd8;
            4'b1110: shift = 4'd7;
            4'b1111: shift = 4'd6;
            4'b0000: shift = 4'd5;
            4'b0001: shift = 4'd4;
            4'b0010: shift = 4'd3;
            4'b0011: shift = 4'd2;
            4'b0100: shift = 4'd1;
            4'b0101: shift = 4'd0;
        endcase
    end

    assign result = {1'b1, in_x_frac, 5'b0_0000} >> reg_stg_0[19:16];

    assign valid_out = reg_stg_1[32];
    assign pow_in_x = reg_stg_1[31:16];
    assign in_x_bypass = reg_stg_1[15:0];

endmodule