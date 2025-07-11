/*
16-bit fixed-point : Q4.12
Testbench for pow2_approx module
Description:
- Applies multiple signed Q4.12 test inputs to the pow2_approx module.
- Converts and displays both input and output in real-number format.
- Verifies approximate 2^x computation by observing output values.
*/

`timescale 1ns/1ps

module pow2_approx_tb;

    reg [15:0] in_pow2;       // Input stimulus in Q4.12 format (signed)
    wire [15:0] out_pow2;     // Output from pow2_approx in Q4.12 format

    // Instantiate pow2_approx module under test
    pow2_approx u_pow2 (
        .in_x(in_pow2),
        .pow2_x(out_pow2)
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
        $display("==== pow2_approx test ====");

        in_pow2 = 16'b1100000000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b1100100000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b1101000000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b1101100000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b1110000000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b1110010000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b1110100000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b1110110000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b1111000000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b1111010000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b1111100000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b1111110000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0000000000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0000010000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0000100000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0000110000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0001000000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0001010000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0001100000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0001110000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0010000000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0010001000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0010010000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0010011000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0010100000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0010101000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0010110000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        in_pow2 = 16'b0010111000000000;
        #10;
        $write("Input: ");
        display_fixed(in_pow2);
        $write("-> Onput: ");
        display_fixed(out_pow2);
        $write("\n");

        $finish;
    end
endmodule