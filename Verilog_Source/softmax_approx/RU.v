/*
16-bit fixed-point : Q4.12
Module : RU
Description:
- Computes non-linear update with selectable scaling and subtraction paths.
- Supports configurable multiplication factor and input selection via control signals.
- Integrates log2_approx and pow2_approx for nonlinear mapping.
*/

module RU (
    input [15:0] in_0,     // First input in Q4.12 format
    input [15:0] in_1,     // Second input in Q4.12 format
    input sel_mult,               // Selector for multiplication factor
    input sel_mux,                // Selector for subtraction path
    input clk,
    input rst,
    input en,
    output [15:0] out_0,    // Intermediate result in Q4.12
    output [15:0] out_1,     // Final result after pow2_approx in Q4.12
    output valid    
);

    wire [15:0] in_0_log2_sub;    // log2_approx result
    wire [15:0] in_0_sub;
    wire [15:0] sub;              // selected sub path
    wire [15:0] mult;             // selected multiplier constant
    wire [15:0] diff;             // difference input
    wire [31:0] mult_result;      // multiplication result (extended)
    wire [15:0] out_x;            // scaled difference (final output before pow2)

    reg [31:0] reg_total;
    reg [15:0] pipe [0:2];

    always @(posedge clk) begin
        if (rst) begin
            reg_total <= 32'd0;
            pipe[0] <= 16'd0;
            pipe[1] <= 16'd0;
            pipe[2] <= 16'd0;
        end
        else if (en) begin
            reg_total <= {in_1, in_0};
            pipe[0] <= reg_total[31:16];
            pipe[1] <= pipe[0];
            pipe[2] <= pipe[1];
        end
    end


    assign mult = (sel_mult) ? 16'b0001_0111_0001_0010 : 16'b0001_0000_0000_0000;
    assign sub = (sel_mux) ? in_0_sub : in_0_log2_sub;

    sub_FX16 SUB(
        .A(pipe[2]),
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

    log2_approx LOG2(
        .in_x(reg_total[15:0]),
        .clk(clk),
        .rst(rst),
        .en(en),
        .ready(1'b1),
        .log2_x(in_0_log2_sub),
        .valid(),
        .out_x(in_0_sub)
    );

    assign out_0 = out_x;

    pow2_approx POW2(
        .in_x(mult_result),
        .clk(clk),
        .rst(rst),
        .en(en),
        .ready(1'b1),
        .pow2_x(out_1),
        .valid(),
        .out_x(out_x)
    );

endmodule