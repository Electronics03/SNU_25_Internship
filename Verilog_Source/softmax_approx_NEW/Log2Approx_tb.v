/*
16-bit fixed-point : Q4.12
Testbench for log2_approx module
Description:
- Applies multiple 16-bit fixed-point test inputs to log2_approx.
- Displays both input and output in real-number format.
- Uses a task to convert Q4.12 to real for readable output.
*/

`timescale 1ns/1ps

module stage1_log2_approx_tb;

    reg valid_in;
    reg clk;
    reg rst;
    reg en;
    reg [15:0] in_0;
    reg [15:0] in_1;
    wire valid_out;
    wire [15:0] log_in_0;
    wire [15:0] in_0_bypass;
    wire [15:0] in_1_bypass;


    initial clk = 0;
    always #5 clk = ~clk;


    stage1_log2_approx u_log2 (
        .valid_in(valid_in),
        .clk(clk),
        .rst(rst),
        .en(en),
        .in_0(in_0),
        .in_1(in_1),
        .valid_out(valid_out),
        .log_in_0(log_in_0),
        .in_0_bypass(in_0_bypass),
        .in_1_bypass(in_1_bypass)
    );


    task display_fixed;
        input [15:0] val;
        real real_val;
        begin
            real_val = $itor($signed(val)) / 4096.0;
            $write("%f", real_val);
        end
    endtask

    initial begin
        #2; rst = 1;
        #10; rst = 0;
        #10; en = 1;

        $display("==== log2_approx test ====");

        in_0 = 16'b0000000001000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000000010000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000000011000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000000100000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000000101000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000000110000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000000111000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000001000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000001010000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000001100000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000001110000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000010000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000010100000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000011000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000011100000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000100000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000101000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000110000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0000111000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0001000000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0001010000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0001100000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0001110000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0010000000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0010010000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0010100000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0010110000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0011000000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0011010000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0011100000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0011110000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0100000000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0100010000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0100100000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0100110000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        in_0 = 16'b0101000000000000;
        in_1 = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        $finish;
    end
endmodule