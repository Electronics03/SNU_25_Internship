/*
16-bit fixed-point : Q4.12
stage3_pow2_approx_tb (Testbench)
Description:
- Testbench for the stage3_pow2_approx module.
- Generates clock, reset, enable, and valid signals to drive the DUT.
- Applies multiple 16-bit fixed-point test inputs covering a range of values.
- Uses display_fixed task to print real-number interpretations of inputs and outputs.
- Verifies 2^x approximation by displaying bypassed inputs and computed outputs.
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

    task display_fixed;
        input [15:0] val;
        real real_val;
        begin
            real_val = $itor($signed(val)) / 1024.0;
            $write("%f", real_val);
        end
    endtask

    initial begin
        #2; rst = 1;
        #10; rst = 0;
        #10; en = 1;

        $display("==== pow2_approx test ====");

        in_x = 16'b100110_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;


        in_x = 16'b101000_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111100_1000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111101_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111101_1000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111110_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111110_0100000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111110_1000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111110_1100000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111111_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111111_0100000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111111_1000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111111_1100000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000000_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000000_0100000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000000_1000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000000_1100000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000001_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000001_0100000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000001_1000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000001_1100000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000010_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000010_0010000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000010_0100000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000010_0110000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000010_1000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000010_1010000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000010_1100000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000011_1100000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000100_1100101110;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b000100_1111111111;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        #10;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");
        #10;
        $finish;
    end
endmodule