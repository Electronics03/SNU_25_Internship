`timescale 1ns/1ps

module FSM_tb #(
    parameter N = 64
);
    reg clk;
    wire en;
    reg rst;

    wire valid_in;
    wire [N*16-1:0] in_x_flat;

    wire valid_out;
    wire [N*16-1:0] prob_flat;

    initial clk = 0;
    always #5 clk = ~clk;

    FSM #(.N(64)) FSM(
        .clk(clk),
        .en(en),
        .rst(rst),
        .valid_in(valid_in),
        .data(in_x_flat)
    );

    softmax #(.N(64)) SOFTMAX(
        .clk(clk),
        .en(en),
        .rst(rst),
        .valid_in(valid_in),
        .in_x_flat(in_x_flat),
        .valid_out(valid_out),
        .prob_flat(prob_flat)
    );

    initial begin
        #2; rst = 1;
        #10; rst = 0;
        #2000;
    end
endmodule