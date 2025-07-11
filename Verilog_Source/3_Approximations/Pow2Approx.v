/*
16-bit fixed-point : Q4.12
Input  : in_x  (16-bit signed)
Output : pow2_x (16-bit signed)
Description:
Approximates 2^x using integer and fractional decomposition.
- Integer part controls left/right shift (scaling by 2^int_part).
- Fractional part approximated as (1 + frac) for 2^frac ≈ 1 + frac.
Implements 2^x ≈ 2^int_part * (1 + frac) using simple shift and add.
*/

module pow2_approx(
    input wire signed [15:0] in_x,
    output wire signed [15:0] pow2_x
);

    wire signed [3:0] int_part;     // Integer part of exponent (signed)
    wire [11:0] frac_part;          // Fractional part of exponent (unsigned)
    
    wire signed [15:0] one_plus_frac; // Linear approximation term (1 + frac) in Q4.12
    wire signed [31:0] mult_result;   // Intermediate result after shift

    /*
    Decompose input:
    - int_part  : top 4 bits represent integer exponent
    - frac_part : lower 12 bits represent fractional exponent
    */
    assign int_part = in_x[15:12];
    assign frac_part = in_x[11:0];

    /*
    Approximate 2^frac using (1 + frac).
    - Constructs (1 + frac) in Q4.12 format.
    */
    assign one_plus_frac = {4'b0001, frac_part};

    /*
    Compute 2^int_part * (1 + frac):
    - If int_part >= 0: shift left (scaling up)
    - If int_part < 0 : shift right (scaling down)
    */
    assign mult_result = (int_part >= 0) ? (one_plus_frac <<< int_part) : (one_plus_frac >>> (-int_part));
    
    /*
    Output:
    - Lower 16 bits of the scaled approximation.
    */
    assign pow2_x = mult_result[15:0];
endmodule
