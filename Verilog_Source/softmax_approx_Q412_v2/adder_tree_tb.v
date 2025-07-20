/*
16-bit fixed-point : Q4.12
add_tree_tb (Testbench)
Description:
- Testbench for the add_tree module with N=8 inputs.
- Generates clock and reset signals, initializes test input vectors.
- Packs multiple 16-bit fixed-point values into flattened bus format.
- Applies inputs to the DUT and monitors output sum and valid signal.
- Displays simulation progress and results for verification.
*/

`timescale 1ns/1ps

module add_tree_tb;

    parameter N = 8;

    reg valid_in;
    reg clk;
    reg rst;
    reg en;
    reg [N*16-1:0] in_0_flat;
    reg [N*16-1:0] in_1_flat;

    wire [15:0] out;
    wire valid_out;
    wire [N*16-1:0] out_prop;

    add_tree #(.N(N)) DUT (
        .valid_in(valid_in),
        .clk(clk),
        .rst(rst),
        .en(en),
        .in_0_flat(in_0_flat),
        .in_1_flat(in_1_flat),
        .out(out),
        .out_prop(out_prop),
        .valid_out(valid_out)
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

        in_1_flat = 0;
        in_0_flat = 16'd23;

        for (i = 0; i < N; i = i + 1) begin
            in_1_flat = in_1_flat | (in_arr[i] << (i*16));
        end

        #10;
        rst = 0;
        valid_in = 1;
        en = 1;
        #10;
        
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
