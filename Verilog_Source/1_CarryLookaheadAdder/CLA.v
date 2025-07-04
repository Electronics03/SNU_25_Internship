module CLA #(parameter N = 8) (
        input wire sub,
        input wire [N-1:0] x,
        input wire [N-1:0] y,
        output wire [N-1:0] sum,
        output wire carry,
        output wire overflow
    );

        wire [N-1:0] G;
        wire [N-1:0] P;
        wire [N:0] C;

        genvar i;
        generate 
            for (i = 0; i < N; i = i + 1) begin: cal_GP
                assign P[i] = x[i] ^ (y[i]^sub);
                assign G[i] = x[i] & (y[i]^sub);
            end
        endgenerate

        assign C[0] = sub;
        generate
            for (i = 0; i < N; i = i + 1 ) begin: cal_C
                assign C[i+1] = G[i] | (P[i] & C[i]);
            end
        endgenerate

        generate
            for (i = 0; i < N; i = i + 1 ) begin: cal_sum
                assign sum[i]= P[i] ^ C[i];
            end
        endgenerate

        assign carry = C[N];
        assign overflow = C[N-1] ^ C[N];
endmodule