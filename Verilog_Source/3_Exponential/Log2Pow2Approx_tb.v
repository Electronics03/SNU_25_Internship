`timescale 1ns/1ps

module approx_tb;

    reg [15:0] in_log2;
    wire [15:0] out_log2;

    reg signed [15:0] in_pow2;
    wire signed [15:0] out_pow2;

    log2_approx u_log2 (
        .in_x(in_log2),
        .log2_x(out_log2)
    );

    pow2_approx u_pow2 (
        .in_x(in_pow2),
        .pow2_x(out_pow2)
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
        $display("==== log2_approx test ====");

        in_log2 = 16'b0000000001000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000000010000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000000011000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000000100000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000000101000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000000110000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000000111000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000001000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000001010000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000001100000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000001110000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000010000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000010100000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000011000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000011100000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000100000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000101000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000110000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0000111000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0001000000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0001010000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0001100000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0001110000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0010000000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0010010000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0010100000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0010110000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0011000000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0011010000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0011100000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0011110000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0100000000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0100010000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0100100000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0100110000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

        in_log2 = 16'b0101000000000000;
        #10;
        $write("Input: ");
        display_fixed(in_log2);
        $write("-> Onput: ");
        display_fixed(out_log2);
        $write("\n");

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
    end
endmodule