`timescale 1ns/1ps
module Adder_tb #( parameter N = 8);

    reg sub;
    reg signed [N-1:0] x;
    reg signed [N-1:0] y;

    wire signed [N-1:0] sum_R;
    wire carry_R;
    wire overflow_R;

    wire signed [N-1:0] sum_L;
    wire carry_L;
    wire overflow_L;

    CLA ADDER_CLA(
        .sub(sub),
        .x(x),
        .y(y),
        .sum(sum_L),
        .carry(carry_L),
        .overflow(overflow_L)
    );

    RCA ADDER_RCA(
        .sub(sub),
        .x(x),
        .y(y),
        .sum(sum_R),
        .carry(carry_R),
        .overflow(overflow_R)
    );
    initial begin
        $monitor(
            "RCA: %d (S=%b) %d = %d (C=%b, O=%b)\nCLA: %d (S=%b) %d = %d (C=%b, O=%b)",
            x, sub, y, sum_R, carry_R, overflow_R,
            x, sub, y, sum_L, carry_L, overflow_L
        );

        x=123;  y=-80;  sub=1'b0;   #10;
        x=-12;  y=53;   sub=1'b0;   #10;
        x=8;    y=3;    sub=1'b0;   #10;
        x=5;    y=-8;   sub=1'b1;   #10;
        x=2;    y=1;    sub=1'b1;   #10;
        x=-12;  y=-23;  sub=1'b1;   #10;
        x=127;  y=127;  sub=1'b0;   #10;
    end

endmodule