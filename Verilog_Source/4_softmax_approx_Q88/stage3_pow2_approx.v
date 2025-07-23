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
    reg [32:0] reg_1;

    wire [3:0] int_part;
    wire [3:0] count;
    wire [15:0] result;

    always @(posedge clk) begin
        if (rst) begin
            reg_0 <= 17'd0;
            reg_1 <= 33'd0;
        end
        else if (en) begin
            reg_0 <= {valid_in, in_x};
            reg_1 <= {reg_0[16], result, reg_0[15:0]};
        end
    end

    assign int_part = reg_0[15:8];
    assign count = {int_part[3], ~int_part[2], ~int_part[1], ~int_part[0]};
    assign result = {1'b1, reg_0[7:0], 7'd0} >> count;

    assign valid_out = reg_1[32];
    assign pow_in_x = reg_1[31:16];
    assign in_x_bypass = reg_1[15:0];
endmodule