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
    input  [N*16-1:0] in_x_flat,   // Flattened N inputs (each 16-bit Q4.12)
    input  [15:0] max_x,           // Maximum value used for numerical stability
    output [N*16-1:0] prob_flat    // Flattened N outputs (softmax probabilities)
);
    wire [15:0] in_x [0:N-1];      // Unpacked input array
    wire [15:0] prob [0:N-1];      // Unpacked output probabilities

    genvar i;
    generate
        // Unpack flattened inputs and pack flattened outputs
        for (i = 0; i < N; i = i + 1) begin
            assign in_x[i] = in_x_flat[i*16 +: 16];
            assign prob_flat[i*16 +: 16] = prob[i];
        end
    endgenerate

    wire signed [15:0] sum [0:N-1];       // Stage 1 exp outputs
    wire signed [15:0] total_sum [N:0];   // Cumulative sum of exp outputs
    wire signed [15:0] y [N-1:0];         // Stage 1 intermediate scaled diffs

    /*
    Initialize cumulative sum.
    total_sum[0] starts at zero.
    */
    assign total_sum[0] = 16'b0000_0000_0000_0000;

    /*
    Stage 1: Compute (x_i - max_x) * log2(e), then exp.
    - Uses RU module with sel_mult=1, sel_mux=1.
    - y[i] = scaled diff
    - sum[i] = exp approximation
    */
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

    /*
    Compute cumulative sum of all exp outputs for denominator.
    total_sum[N] holds the final sum.
    */
    generate
        for (i = 0; i < N; i = i + 1) begin
            assign total_sum[i+1] = total_sum[i] + sum[i];
        end
    endgenerate

    /*
    Stage 2: Compute (log2_sum - y_i) * 1, then exp.
    - Uses RU module with sel_mult=0, sel_mux=0.
    - Outputs final softmax probability for each input.
    */
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