/*
16-bit fixed-point : Q4.12
RU_tb (Testbench)
Description:
- Testbench for the RU (Reduction Unit) module.
- Generates clock, reset, enable, and valid signals to drive the DUT.
- Applies representative test inputs for both stages of RU computation.
- Uses display_fixed task to print inputs and outputs in real-number format.
- Verifies pipelined log2, subtraction, multiplication, and exp2 approximation sequence.
- Displays input and output values for both configured operation modes.
*/

`timescale 1ns/1ps

module RU_tb;

    reg clk;
    reg rst;
    reg en;
    reg valid_in;
    wire valid_out;

    initial clk = 0;
    always #5 clk = ~clk;

    reg signed [15:0] in_0;
    reg signed [15:0] in_1;
    reg sel_mult;
    reg sel_mux;
    wire signed [15:0] out_0;
    wire signed [15:0] out_1;

    RU uut (
        .valid_in(valid_in),
        .in_0(in_0),
        .in_1(in_1),
        .sel_mult(sel_mult),
        .sel_mux(sel_mux),
        .clk(clk),
        .rst(rst),
        .en(en),
        .out_0(out_0),
        .out_1(out_1),
        .valid_out(valid_out)
    );

    task display_fixed;
        input [15:0] val;
        real real_val;
        begin
            real_val = $itor($signed(val)) / 1024.0;
            $display("%h = %f", val, real_val);
        end
    endtask


    initial begin
        #2; rst = 1;
        #10; rst = 0;
        #10; en = 1;

        $display("=== RU Module Test Start ===");

        $display("Stage 1: (x_i - max) * log2(e)");
        in_0 = 16'b000010_0100_0010_01;
        in_1 = 16'b000001_0101_0010_01;
        sel_mux = 1;
        sel_mult = 1;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        #100;
        $display("-- Stage 1 output --");
        $display("Input x_i ="); display_fixed(in_1);
        $display("Input max ="); display_fixed(in_0);
        $display("out_0 (scaled diff) ="); display_fixed(out_0);
        $display("out_1 (pow2 approx) ="); display_fixed(out_1);
        $display("");

        $display("Stage 2: (log2_sum - y_i) * 1");
        in_0 = 16'b000001_0101_0010_01;
        in_1 = 16'b111110_0011_0001_01;
        sel_mux = 0;
        sel_mult = 0;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        #100;
        $display("-- Stage 2 output --");
        $display("Input sum ="); display_fixed(in_0);
        $display("Input y_i ="); display_fixed(in_1);
        $display("out_0 (diff) ="); display_fixed(out_0);
        $display("out_1 (pow2 approx) ="); display_fixed(out_1);
        $display("");

        $display("=== RU Module Test End ===");
        #100;
        $finish;
    end

endmodule
