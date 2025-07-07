module CLA #(parameter N = 8) (
    input wire C_in,
    input wire [N-1:0] x,
    input wire [N-1:0] y,
    output wire [N-1:0] sum,
    output wire C_out,
    output wire overflow
);
        wire [N-1:0] G;
        wire [N-1:0] P;
        wire [N:0] C;

        genvar i;
        generate 
            for (i = 0; i < N; i = i + 1) begin: cal_GP
                assign P[i] = x[i] ^ (y[i]);
                assign G[i] = x[i] & (y[i]);
            end
        endgenerate

        assign C[0] = C_in;
        generate
            for (i = 0; i < N; i = i + 1) begin: cal_C
                assign C[i+1] = G[i] | (P[i] & C[i]);
            end
        endgenerate

        generate
            for (i = 0; i < N; i = i + 1) begin: cal_sum
                assign sum[i]= P[i] ^ C[i];
            end
        endgenerate

        assign C_out = C[N];
        assign overflow = C[N-1] ^ C[N];
endmodule