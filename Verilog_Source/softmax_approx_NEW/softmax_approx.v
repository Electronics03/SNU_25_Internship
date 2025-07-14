/*
16-bit fixed-point : Q4.12
Module : softmax
Parameter : N (number of inputs, default 8)
Description:
- Computes approximate softmax over N fixed-point inputs.
- Stage 1: For each input x_i, computes (x_i - max) * log2(e) and exp.
- Sums all exp results to get denominator.
- Stage 2: For each input, computes (log2_sum - y_i) * 1 and exp.
- Outputs final softmax probabilities in Q4.12 format.
*/

module softmax #(parameter N = 8)(
    input [N*16-1:0] in_x_flat,   // Flattened N inputs (each 16-bit Q4.12)
    input clk,
    input en,
    input rst,
    input  [15:0] max_x,           // Maximum value used for numerical stability
    output [N*16-1:0] prob_flat,    // Flattened N outputs (softmax probabilities)
    output [N*16-1:0] add_in_flat_0
);
    wire [15:0] in_x [0:N-1];      // Unpacked input array
    wire [15:0] prob [0:N-1];      // Unpacked output probabilities
    

    wire [15:0] add_in [0:N-1];
    wire [15:0] y [0:N-1];
    wire [N*16-1:0] y_flat;
    wire [N*16-1:0] add_in_flat;
    wire [15:0] add_out;
    wire [N*16-1:0] add_out_prop_flat;
    wire [15:0] add_out_prop [0:N-1];

    assign add_in_flat_0 = add_in_flat;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin
            assign in_x[i] = in_x_flat[i*16 +: 16];
            assign add_in_flat[i*16 +: 16] = add_in[i];
            assign y_flat[i*16 +: 16] = y[i];
            assign add_out_prop[i] = add_out_prop_flat[i*16 +: 16];
            assign prob_flat[i*16 +: 16] = prob[i];
        end
    endgenerate

    generate
        for (i = 0; i < N; i = i + 1) begin
            RU FIRSTSTAGE(
                .in_0(max_x),
                .in_1(in_x[i]),
                .sel_mult(1'b1),
                .sel_mux(1'b1),
                .out_0(y[i]),
                .out_1(add_in[i]),
                .clk(clk),
                .rst(rst),
                .en(en)
            );
        end
    endgenerate

    add_tree #(.N(N)) ADDT(
        .clk(clk),
        .rst(rst),
        .en(en),
        .in_0_flat(y_flat),
        .in_1_flat(add_in_flat),
        .out(add_out),
        .out_prop(add_out_prop_flat)
    );

    generate
        for (i = 0; i < N; i = i + 1) begin
            RU SECONDSTAGE(
                .in_0(add_out),
                .in_1(add_out_prop[i]),
                .sel_mult(1'b0),
                .sel_mux(1'b0),
                .out_0(),
                .out_1(prob[i]),
                .clk(clk),
                .rst(rst),
                .en(en)
            );
        end
    endgenerate
endmodule