module softmax #(parameter N = 8)(
    input  [N*16-1:0] in_x_flat,
    input  [15:0] max_x,
    output [N*16-1:0] prob_flat
);
    wire [15:0] in_x [0:N-1];
    wire [15:0] prob [0:N-1];

    genvar i;
    generate
    for (i = 0; i < N; i = i + 1) begin
        assign in_x[i] = in_x_flat[i*16 +: 16];
        assign prob_flat[i*16 +: 16] = prob[i];
    end
    endgenerate

    wire signed [15:0] sum [0:N-1];
    wire signed [15:0] total_sum [N:0];
    wire signed [15:0] y [N-1:0];

    assign total_sum[0] = 16'b0000_0000_0000_0000;

    generate
        for (i = 0; i < N; i = i + 1) begin
            RU FIRSTSTAGE(
                .in_0(max_x),
                .in_1(in_x[i]),
                .sel_mult(1'b1),
                .sel_mux(1'b1),
                .out_0(y[i]),
                .out_1(sum[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < N; i = i + 1) begin
            assign total_sum[i+1] = total_sum[i] + sum[i];
        end
    endgenerate

    generate
        for (i = 0; i < N; i = i + 1) begin
            RU SECONDSTAGE(
                .in_0(total_sum[N]),
                .in_1(y[i]),
                .sel_mult(1'b0),
                .sel_mux(1'b0),
                .out_0(),
                .out_1(prob[i])
            );
        end
    endgenerate
endmodule