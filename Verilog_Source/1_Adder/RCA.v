module RCA #(parameter N = 8) (
    input wire C_in,
    input wire [N-1:0] x,
    input wire [N-1:0] y,
    output wire [N-1:0] sum,
    output wire C_out,
    output wire overflow
);
    wire [N:0] C;
    assign C[0] = C_in;
    
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin: ADDER
            FullAdder FA(
                .C_in(C[i]),
                .x(x[i]),
                .y(y[i]),
                .sum(sum[i]),
                .C_out(C[i+1])
            );
        end
    endgenerate
    assign overflow = C[N] ^ C[N-1];
    assign C_out = C[N];
endmodule

module FullAdder (
    input wire C_in,
    input wire x,
    input wire y,
    output wire sum,
    output wire C_out
);
    xor SUM(sum, C_in, x, y);
    or CARRY(C_out, (C_in & x), (C_in & y), (x & y));
endmodule