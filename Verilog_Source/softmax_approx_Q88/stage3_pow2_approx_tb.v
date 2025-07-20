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
            real_val = $itor($signed(val)) / 256.0;
            $write("%f", real_val);
        end
    endtask

    initial begin
        #2; rst = 1;
        #10; rst = 0;
        #10; en = 1;

        $display("==== pow2_approx test ====");

        in_x = 16'b1111110000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;

        in_x = 16'b1111110010000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1111110100000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1111110110000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1111111000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1111111001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1111111010000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1111111011000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1111111100000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1111111101000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1111111110000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b1111111111000000;
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

        in_x = 16'b0000000001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000000010000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000000011000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000000100000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000000101000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000000110000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000000111000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000001000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000001000100000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000001001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000001001100000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000001010000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000001010100000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000001011000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b0000001011100000;
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