/*
16-bit fixed-point : Q4.12
Testbench for RU module
Description:
- Stimulates RU with specific scenarios emulating typical two-stage update.
- Stage 1: (x_i - max) * log2(e) using sel_mult=1, sel_mux=1.
- Stage 2: (log2_sum - y_i) * 1 using sel_mult=0, sel_mux=0.
- Prints input and output values in both hex and real-number formats.
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

    reg signed [15:0] in_0;     // Input in Q4.12
    reg signed [15:0] in_1;     // Input in Q4.12
    reg sel_mult;               // Multiplier selection
    reg sel_mux;                // Mux selection

    wire signed [15:0] out_0;   // Intermediate output (scaled difference)
    wire signed [15:0] out_1;   // Final output after pow2_approx

    // Instantiate the RU module under test
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

    /*
    Task to print 16-bit fixed-point Q4.12 as real value with hex.
    */
    task display_fixed;
        input [15:0] val;
        real real_val;
        begin
            real_val = $itor($signed(val)) / 4096.0;
            $display("%h = %f", val, real_val);
        end
    endtask

    /*
    Test sequence:
    - Stage 1: Simulate (x_i - max) * log2(e)
    - Stage 2: Simulate (log2_sum - y_i) * 1
    */
    initial begin
        #2; rst = 1;
        #10; rst = 0;
        #10; en = 1;

        $display("=== RU Module Test Start ===");

        // Stage 1
        $display("Stage 1: (x_i - max) * log2(e)");
        in_0 = 16'h2400;  // Example max value
        in_1 = 16'h1000;  // Example x_i
        sel_mux = 1;
        sel_mult = 1;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        #500;
        $display("-- Stage 1 output --");
        $display("Input x_i ="); display_fixed(in_1);
        $display("Input max ="); display_fixed(in_0);
        $display("out_0 (scaled diff) ="); display_fixed(out_0);
        $display("out_1 (pow2 approx) ="); display_fixed(out_1);
        $display("");

        // Stage 2
        $display("Stage 2: (log2_sum - y_i) * 1");
        in_0 = 16'h1800;  // Example log2_sum
        in_1 = 16'b1110_0011_0001_0110;  // Example y_i
        sel_mux = 0;
        sel_mult = 0;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        #500;
        $display("-- Stage 2 output --");
        $display("Input sum ="); display_fixed(in_0);
        $display("Input y_i ="); display_fixed(in_1);
        $display("out_0 (diff) ="); display_fixed(out_0);
        $display("out_1 (pow2 approx) ="); display_fixed(out_1);
        $display("");

        $display("=== RU Module Test End ===");
        $finish;
    end

endmodule
