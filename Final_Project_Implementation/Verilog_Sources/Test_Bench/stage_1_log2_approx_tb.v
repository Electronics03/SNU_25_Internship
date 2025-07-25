`timescale 1ns/1ps

module stage1_log2_approx_tb;

    reg clk;
    reg en;
    reg rst;

    reg valid_in;
    reg [15:0] in_0;
    reg [15:0] in_1;

    wire valid_out;
    wire [15:0] log_in_0;

    wire [15:0] in_0_bypass;
    wire [15:0] in_1_bypass;

    initial clk = 0;
    always #5 clk = ~clk;


    stage1_log2_approx u_log2 (
        .clk(clk),
        .en(en),
        .rst(rst),

        .valid_in(valid_in),
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
            real_val = $itor($signed(val)) / 1024.0;
            $write("%f", real_val);
        end
    endtask

    initial begin
        #2; rst = 1;
        #10; rst = 0;
        #10; en = 1;

        $display("==== log2_approx test ====");

        in_0 = 16'b000000_0000000001;
        in_1 = 16'b000000_0001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;

        in_0 = 16'b000000_0000000010;
        in_1 = 16'b000000_0001000000;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;

        in_0 = 16'b000000_0000000100;
        in_1 = 16'b000000_0001000000;
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

        in_0 = 16'b000000_0000001000;
        in_1 = 16'b000000_0001000000;
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
    
        in_0 = 16'b000000_0000010000;
        in_1 = 16'b000000_0001000000;
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

        in_0 = 16'b000000_0000100000;
        in_1 = 16'b000000_0001000000;
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

        in_0 = 16'b000000_0001000000;
        in_1 = 16'b000000_0001000000;
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

        in_0 = 16'b000000_0010000000;
        in_1 = 16'b000000_0001000000;
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

        in_0 = 16'b000000_0100000000;
        in_1 = 16'b000000_0001000000;
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

        in_0 = 16'b000000_1000000000;
        in_1 = 16'b000000_0001000000;
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

        in_0 = 16'b000001_0000000000;
        in_1 = 16'b000000_0001000000;
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

        in_0 = 16'b000010_0000000000;
        in_1 = 16'b000000_0001000000;
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

        in_0 = 16'b000100_0000000000;
        in_1 = 16'b000000_0001000000;
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

        in_0 = 16'b001000_0000000000;
        in_1 = 16'b000000_0001000000;
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

        in_0 = 16'b010000_0000000000;
        in_1 = 16'b000000_0001000000;
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

        in_0 = 16'b011111_1111111111;
        in_1 = 16'b000000_0001000000;
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

        #10;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        #10;
        $write("Input: ");
        $write("\n");
        display_fixed(in_0_bypass);
        $write("\n");
        display_fixed(in_1_bypass);
        $write("\n");
        $write("-> Onput: ");
        display_fixed(log_in_0);
        $write("\n");

        #10;
        $finish;
    end
endmodule
