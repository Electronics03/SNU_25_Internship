`timescale 1ns/1ps

module add_tree_tb;

    parameter N = 8;

    reg clk;
    reg rst;
    reg ready;
    reg en;
    reg [N*16-1:0] in_flat;
    wire [15:0] out;
    wire valid;
    wire [N*16-1:0] out_prop;

    add_tree #(.N(N)) DUT (
        .clk(clk),
        .rst(rst),
        .en(en),
        .in_flat(in_flat),
        .out(out),
        .out_prop(out_prop)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    reg [15:0] in_arr [0:N-1];

    integer i;

    initial begin
        $display("---- Starting add_tree_module TB ----");

        in_arr[0]  = 16'h0100;  // 1.0
        in_arr[1]  = 16'h0200;  // 2.0
        in_arr[2]  = 16'h0300;  // 3.0
        in_arr[3]  = 16'h0400;  // 4.0
        in_arr[4]  = 16'h0500;  // 5.0
        in_arr[5]  = 16'h0600;  // 6.0
        in_arr[6]  = 16'h0700;  // 7.0
        in_arr[7]  = 16'h0800;  // 8.0

        rst = 1;
        in_flat = 0;
        #20;
        rst = 0;
        ready = 1;
        en = 1;
        #10;

        in_flat = 0;
        for (i = 0; i < N; i = i + 1) begin
            in_flat = in_flat | (in_arr[i] << (i*16));
        end

        $display("[TB] Input vector loaded at time %0t", $time);
        #500;
        $display("---- Simulation Complete ----");
        $finish;
    end

    always @(posedge clk) begin
        if (rst) begin
            $display("Time=%0t ns | Adder Tree OUT = %h", $time, out);
        end
    end

endmodule
