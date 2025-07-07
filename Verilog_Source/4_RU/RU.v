module RU (
    input  signed [15:0] in_0,
    input  signed [15:0] in_1,
    input  sel_mult,
    input  sel_mux,
    output signed [15:0] out_0,
    output signed [15:0] out_1
);

    wire signed [15:0] in_0_sub;
    wire signed [15:0] sub;
    wire signed [15:0] mult;
    wire signed [15:0] diff;
    wire signed [31:0] mult_result;
    wire signed [15:0] out_x;

    // LUT constant selection
    assign mult = (sel_mult) ? 16'sb0001_0111_0001_0010 : 16'sb0001_0000_0000_0000;

    // MUX selection for Stage 1 / Stage 2
    assign sub = (sel_mux) ? in_0 : in_0_sub;

    // Difference
    assign diff = in_1 - sub;

    // Multiplication (Q4.12 * Q4.12 = Q8.24)
    assign mult_result = $signed(diff) * $signed(mult);

    // Scaling back to Q4.12 (shift right 12)
    assign out_x = mult_result[27:12];

    // log2 approx
    log2_approx LOG2(
        .in_x(in_0),
        .log2_x(in_0_sub)
    );

    // Outputs
    assign out_0 = out_x;

    pow2_approx POW2(
        .in_x(out_x),
        .pow2_x(out_1)
    );

endmodule