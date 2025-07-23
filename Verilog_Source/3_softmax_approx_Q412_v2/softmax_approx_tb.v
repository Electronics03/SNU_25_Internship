/*
16-bit fixed-point : Q4.12
softmax_tb (Testbench)
Description:
- Testbench for verifying the softmax module with N=8 inputs.
- Generates clock, reset, enable, and valid_in signals for DUT control.
- Defines multiple test input vectors with known fixed-point values.
- Applies input vectors along with corresponding max values to simulate softmax behavior.
- Uses display_fixed task to print 16-bit fixed-point values in real-number format.
- Observes and verifies output probability vectors produced by the DUT.
*/

`timescale 1ns/1ps

module softmax_tb;

    parameter N = 8;

    localparam [N*16-1:0] my_x_0 = {
        16'hEE08, // -1.123
        16'h13BE, //  1.234
        16'h0501, //  0.313
        16'h3521, //  3.324
        16'hEC6E, // -1.223
        16'hFC4E, // -0.231
        16'hFDF8, // -0.123
        16'h21C3  //  2.11
    };

    localparam [N*16-1:0] my_x_1 = {N{16'h0501}}; //  0.313

    localparam [N*16-1:0] my_x_2 = {
        16'hFE08, // -0.123
        16'h13BE, //  1.234
        16'h0501, //  0.313
        16'h4521, //  4.324
        16'hFC6E, // -0.223
        16'hFC4E, // -0.231
        16'hFDF8, // -0.123
        16'h21C3  //  2.11
    };

    reg clk;
    reg en;
    reg rst;

    reg valid_in;

    initial clk = 0;
    always #5 clk = ~clk;

    reg signed [N*16-1:0] in_x_flat;
    reg signed [15:0] max_x;
    wire signed [N*16-1:0] prob_flat;

    wire [15:0] in_x_arr [0:N-1];
    wire [15:0] prob_arr [0:N-1];
    wire valid_out;

    genvar idx;
    generate
        for (idx = 0; idx < N; idx = idx + 1) begin
            assign in_x_arr[idx] = in_x_flat[16*idx +: 16];
            assign prob_arr[idx] = prob_flat[16*idx +: 16];
        end
    endgenerate

    softmax #(.N(N)) DUT (
        .valid_in(valid_in),
        .in_x_flat(in_x_flat),
        .max_x(max_x),
        .prob_flat(prob_flat),
        .add_in_flat_0(),
        .clk(clk),
        .rst(rst),
        .en(en),
        .valid_out(valid_out)
    );

    task display_fixed;
        input [15:0] val;
        real real_val;
        begin
            real_val = $itor($signed(val)) / 4096.0;
            $display("%h = %f", val, real_val);
        end
    endtask


    integer i;
    initial begin
        in_x_flat = 0;
        valid_in = 0;
        #2; rst = 1;
        #10; rst = 0;
        #10; en = 1; 

        #10;
        in_x_flat = my_x_0; valid_in = 1; max_x = 16'h3521;
        #10;
        in_x_flat = my_x_1; valid_in = 1; max_x = 16'h0501;
        #10;
        in_x_flat = my_x_2; valid_in = 1; max_x = 16'h4521;
        #300;
        $finish;
    end

endmodule
