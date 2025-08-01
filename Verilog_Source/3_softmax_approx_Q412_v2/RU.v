/*
16-bit fixed-point : Q4.12
RU (Reduction Unit) module
Description:
- Composite pipeline unit performing log2, subtraction, multiplication, and exp2 approximation.
- Uses stage1_log2_approx to compute log2 of input with bypassed data.
- Applies selectable subtraction and multiplication with fixed-point scaling.
- Feeds result to stage3_pow2_approx for 2^x approximation.
- Manages 5-stage valid signal pipeline for synchronization.
- Outputs two 16-bit fixed-point results and a valid signal for downstream modules.
*/

module RU (
    input valid_in,
    input [15:0] in_0,
    input [15:0] in_1,
    input sel_mult,
    input sel_mux,
    input clk,
    input rst,
    input en,
    output [15:0] out_0,
    output [15:0] out_1,
    output valid_out
);
    wire [15:0] log_in_0;
    wire [15:0] in_0_bypass;
    wire [15:0] in_1_bypass;

    wire [15:0] sub;
    wire [15:0] mult;

    wire [15:0] diff;
    wire [31:0] mult_result;
    wire [15:0] out_x;

    wire valid_log;
    reg [4:0] valid_pipe;

    always @(posedge clk) begin
        if (rst) begin
            valid_pipe[0] <= 1'b0;
            valid_pipe[1] <= 1'b0;
            valid_pipe[2] <= 1'b0;
            valid_pipe[3] <= 1'b0;
            valid_pipe[4] <= 1'b0;
        end
        else if (en) begin
            valid_pipe[0] <= valid_log;
            valid_pipe[1] <= valid_pipe[0];
            valid_pipe[2] <= valid_pipe[1];
            valid_pipe[3] <= valid_pipe[2];
            valid_pipe[4] <= valid_pipe[3];
        end
    end

    assign mult = (sel_mult) ? 16'b0001_0111_0001_0010 : 16'b0001_0000_0000_0000;
    assign sub = (sel_mux) ? in_0_bypass : log_in_0;

    sub_FX16 SUB(
        .A(in_1_bypass),
        .B(sub),
        .CLK(clk),
        .S(diff)
    );

    mult_FX16 MULT(
        .CLK(clk),
        .A(diff),
        .B(mult),
        .P(mult_result)
    );

    stage1_log2_approx STAGE1 (
        .valid_in(valid_in),
        .clk(clk),
        .rst(rst),
        .en(en),
        .in_0(in_0),
        .in_1(in_1),
        .valid_out(valid_log),
        .log_in_0(log_in_0),
        .in_0_bypass(in_0_bypass),
        .in_1_bypass(in_1_bypass)
    );

    stage3_pow2_approx STAGE2 (
        .valid_in(valid_pipe[4]),
        .clk(clk),
        .rst(rst),
        .en(en),
        .in_x(mult_result[27:12]),
        .valid_out(valid_out),
        .pow_in_x(out_1),
        .in_x_bypass(out_0)
    );

endmodule