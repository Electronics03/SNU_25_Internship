/*
16-bit fixed-point : Q4.12
Testbench for pow2_approx module
Description:
- Applies multiple signed Q4.12 test inputs to the pow2_approx module.
- Converts and displays both input and output in real-number format.
- Verifies approximate 2^x computation by observing output values.
*/

`timescale 1ns/1ps

module stage3_pow2_approx_tb;

    reg valid_in;
    reg clk;
    reg rst;
    reg en;
    reg [15:0] in_x;
    wire valid_out;
    wire [15:0] pow_in_x;
    wire [15:0] in_x_bypass;

    initial clk = 0;
    always #5 clk = ~clk;

    stage3_pow2_approx u_pow2 (
        .valid_in(valid_in),
        .clk(clk),
        .rst(rst),
        .en(en),
        .in_x(in_x),
        .valid_out(valid_out),
        .pow_in_x(pow_in_x),
        .in_x_bypass(in_x_bypass)
    );

    /*
    Task: display_fixed
    Converts 16-bit signed Q4.12 value to real.
    Prints real-valued representation for easier verification.
    */
    task display_fixed;
        input [15:0] val;
        real real_val;
        begin
            real_val = $itor($signed(val)) / 4096.0;
            $write("%f", real_val);
        end
    endtask

    /*
    Main stimulus:
    - Apply a series of test vectors covering negative and positive ranges.
    - Waits 10ns between changes.
    - Prints input and corresponding output for each test case.
    */

    initial begin
        #2; rst = 1;
        #10; rst = 0;
        #10; en = 1;

        $display("==== pow2_approx test ====");

        in_x = 16'b1100000000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1100100000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1101000000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1101100000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1110000000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1110010000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1110100000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1110110000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1111000000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1111010000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1111100000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1111110000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000000000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000010000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000100000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000110000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0001000000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0001010000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0001100000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0001110000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0010000000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0010001000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0010010000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0010011000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0010100000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0010101000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0010110000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0010111000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        $finish;
    end
endmodule