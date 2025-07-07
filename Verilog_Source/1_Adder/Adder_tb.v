`timescale 1ns/1ps
module Adder_tb #( parameter N = 8);

    reg C_in;
    reg signed [N-1:0] x;
    reg signed [N-1:0] y;

    wire signed [N-1:0] sum_R;
    wire C_out_R;
    wire overflow_R;

    wire signed [N-1:0] sum_L;
    wire C_out_L;
    wire overflow_L;

    CLA ADDER_CLA(
        .C_in(C_in),
        .x(x),
        .y(y),
        .sum(sum_L),
        .C_out(C_out_L),
        .overflow(overflow_L)
    );

    RCA ADDER_RCA(
        .C_in(C_in),
        .x(x),
        .y(y),
        .sum(sum_R),
        .C_out(C_out_R),
        .overflow(overflow_R)
    );
    initial begin
        $monitor(
            "RCA: %d (C_in=%b) %d = %d (C=%b, O=%b)\nCLA: %d (C_in=%b) %d = %d (C=%b, O=%b)",
            x, C_in, y, sum_R, C_out_R, overflow_R,
            x, C_in, y, sum_L, C_out_L, overflow_L
        );

        x=123;  y=-80;  C_in=1'b0;   #10;
        x=-12;  y=53;   C_in=1'b0;   #10;
        x=8;    y=3;    C_in=1'b0;   #10;
        x=5;    y=-8;   C_in=1'b1;   #10;
        x=2;    y=1;    C_in=1'b1;   #10;
        x=-12;  y=-23;  C_in=1'b1;   #10;
        x=127;  y=127;  C_in=1'b0;   #10;
    end

endmodule