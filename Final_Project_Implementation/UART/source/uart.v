module product2 (
    input [7:0] in,
    output [7:0] out
);
    assign out = in + in;
endmodule