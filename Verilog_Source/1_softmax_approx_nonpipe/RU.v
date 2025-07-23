/*
16-bit fixed-point : Q4.12
Module : RU
Description:
- Computes non-linear update with selectable scaling and subtraction paths.
- Supports configurable multiplication factor and input selection via control signals.
- Integrates log2_approx and pow2_approx for nonlinear mapping.
*/

module RU (
    input  signed [15:0] in_0,     // First input in Q4.12 format
    input  signed [15:0] in_1,     // Second input in Q4.12 format
    input  sel_mult,               // Selector for multiplication factor
    input  sel_mux,                // Selector for subtraction path
    output signed [15:0] out_0,    // Intermediate result in Q4.12
    output signed [15:0] out_1     // Final result after pow2_approx in Q4.12
);

    wire signed [15:0] in_0_sub;         // log2_approx result
    wire signed [15:0] sub;              // selected sub path
    wire signed [15:0] mult;             // selected multiplier constant
    wire signed [15:0] diff;             // difference input
    wire signed [31:0] mult_result;      // multiplication result (extended)
    wire signed [15:0] out_x;            // scaled difference (final output before pow2)


    assign mult = (sel_mult) ? 16'sb0001_0111_0001_0010 : 16'sb0001_0000_0000_0000;
    assign sub = (sel_mux) ? in_0 : in_0_sub;
    assign diff = in_1 - sub;
    assign mult_result = $signed(diff) * $signed(mult);
    assign out_x = mult_result[27:12];

    log2_approx LOG2(
        .in_x(in_0),
        .log2_x(in_0_sub)
    );

    assign out_0 = out_x;

    pow2_approx POW2(
        .in_x(out_x),
        .pow2_x(out_1)
    );

endmodule