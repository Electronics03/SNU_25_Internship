module unsigned_multiplier_gen #(
    parameter N = 8
)(
    input  wire [N-1:0] x,
    input  wire [N-1:0] y,
    output wire [2*N-1:0] prod
);

    // Internal 2D wires for sum and carry
    wire [N-1:0] sum[N-1:0];
    wire [N-1:0] carry[N-1:0];

    genvar i, j;

    // Generate partial products and carry-save adder network
    generate
        for (i = 0; i < N; i = i + 1) begin : multiplier
            if (i == 0) begin
                // First row: just AND gates
                for (j = 0; j < N; j = j + 1) begin
                    assign sum[j][i]   = x[j] & y[i];
                    assign carry[j][i] = 1'b0;
                end
            end
            else begin
                // Subsequent rows: full adders
                for (j = 0; j < N; j = j + 1) begin
                    if (j == 0) begin
                        assign {carry[j][i], sum[j][i]} = sum[j+1][i-1] + (x[j] & y[i]);
                    end
                    else if (j == N-1) begin
                        assign {carry[j][i], sum[j][i]} = (x[j] & y[i]) + carry[N-1][i-1] + carry[j-1][i];
                    end
                    else begin
                        assign {carry[j][i], sum[j][i]} = (x[j] & y[i]) + sum[j+1][i-1] + carry[j-1][i];
                    end
                end
            end
        end
    endgenerate

    // Assign lower N bits of product
    generate
        for (i = 0; i < N; i = i + 1) begin : low_bit_multiplier
            assign prod[i] = sum[0][i];
        end
    endgenerate

    // Assign higher N-1 bits of product
    generate
        for (i = 1; i < N; i = i + 1) begin : high_bit_multiplier
            assign prod[N+i-1] = sum[i][N-1];
        end
    endgenerate

    // Final MSB carry-out
    assign prod[2*N-1] = carry[N-1][N-1];

endmodule