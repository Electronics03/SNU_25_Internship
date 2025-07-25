`timescale 1ns/1ps

module RU_tb;

    reg clk;
    reg rst;
    reg en;
    reg valid_in;
    wire valid_out;

    initial clk = 0;
    always #5 clk = ~clk;

    reg signed [15:0] in_0;
    reg signed [15:0] in_1;
    reg sel_mult;
    reg sel_mux;
    wire signed [15:0] out_0;
    wire signed [15:0] out_1;

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

    task display_fixed;
        input [15:0] val;
        real real_val;
        begin
            real_val = $itor($signed(val)) / 256.0;
            $display("%h = %f", val, real_val);
        end
    endtask


    initial begin
        #2; rst = 1;
        #10; rst = 0;
        #10; en = 1;

        $display("=== RU Module Test Start ===");

        $display("Stage 1: (x_i - max) * log2(e)");
        in_0 = 16'h0240;
        in_1 = 16'h0100;
        sel_mux = 1;
        sel_mult = 1;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        #100;
        $display("-- Stage 1 output --");
        $display("Input x_i ="); display_fixed(in_1);
        $display("Input max ="); display_fixed(in_0);
        $display("out_0 (scaled diff) ="); display_fixed(out_0);
        $display("out_1 (pow2 approx) ="); display_fixed(out_1);
        $display("");

        $display("Stage 2: (log2_sum - y_i) * 1");
        in_0 = 16'he125;
        in_1 = 16'h2d44;
        sel_mux = 0;
        sel_mult = 0;
        valid_in = 1'b1;
        #5; valid_in = 1'b0;
        #5;
        #100;
        $display("-- Stage 2 output --");
        $display("Input sum ="); display_fixed(in_0);
        $display("Input y_i ="); display_fixed(in_1);
        $display("out_0 (diff) ="); display_fixed(out_0);
        $display("out_1 (pow2 approx) ="); display_fixed(out_1);
        $display("");

        $display("=== RU Module Test End ===");
        #5;
        $finish;
    end

endmodule
