`timescale 1ns/1ps

module stage3_pow2_approx_tb;

    reg clk;
    reg en;
    reg rst;

    reg valid_in;
    reg [15:0] in_x;

    wire valid_out;
    wire [15:0] pow_in_x;
    wire [15:0] in_x_bypass;

    initial clk = 0;
    always #5 clk = ~clk;

    stage3_pow2_approx u_pow2 (
        .clk(clk),
        .en(en),
        .rst(rst),

        .valid_in(valid_in),
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

        in_x = 16'b100000_0000000001;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;

        in_x = 16'b110101_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b110110_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b110111_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111000_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111001_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111010_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111011_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");

        in_x = 16'b111100_0000000000;
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

        in_x = 16'b111110_0000000000;
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

        in_x = 16'b000000_0000000000;
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
        
        in_x = 16'b000010_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");
        
        in_x = 16'b000011_0000000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        $write("Input: ");
        display_fixed(in_x_bypass);
        $write("-> Onput: ");
        display_fixed(pow_in_x);
        $write("\n");
        
        in_x = 16'b000100_0000000000;
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