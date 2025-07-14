/*
16-bit fixed-point : Q4.12
Testbench for log2_approx module
Description:
- Applies multiple 16-bit fixed-point test inputs to log2_approx.
- Displays both input and output in real-number format.
- Uses a task to convert Q4.12 to real for readable output.
*/

`timescale 1ns/1ps

module log2_approx_tb;

    reg clk;
    reg rst;
    reg en;
    reg ready;
    wire valid;

    initial clk = 0;
    always #5 clk = ~clk;

    reg [15:0] in_log2;        // Test input in Q4.12 format
    wire [15:0] out_log2;      // Output from log2_approx (Q4.12)
    wire [15:0] out_x;  

    // Instantiate the DUT (Device Under Test)
    log2_approx u_log2 (
        .in_x(in_log2),
        .clk(clk),
        .rst(rst),
        .en(en),
        .ready(ready),
        .log2_x(out_log2),
        .valid(valid),
        .out_x(out_x)
    );

    /*
    Task to display fixed-point Q4.12 as real number.
    Converts signed 16-bit value to real by dividing by 4096.0.
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
    Apply a sequence of test vectors.
    Print input and corresponding output for verification.
    */

    initial begin
        #2; rst = 1;
        #10; rst = 0;
        #10; en = 1;

        $display("==== log2_approx test ====");

        in_log2 = 16'b0000000001000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000000010000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000000011000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000000100000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000000101000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000000110000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000000111000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000001000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000001010000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000001100000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000001110000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000010000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000010100000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000011000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000011100000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000100000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000101000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000110000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000111000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0001000000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0001010000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0001100000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0001110000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0010000000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0010010000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0010100000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0010110000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0011000000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0011010000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0011100000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0011110000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0100000000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0100010000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0100100000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0100110000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0101000000000000;
        ready = 1'b1;
        #5; ready = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        $finish;
    end
endmodule