/*
Add Tree Module

16-bit fixed-point: Q6.10
Description:
- Computes the total sum of N signed 16-bit inputs using a pipelined binary adder tree.

Inputs:
- clk              : Clock signal
- en               : Enable signal for operation
- rst              : Active-high synchronous reset
- valid_in         : Valid signal for current inputs
- in_0_flat[N*16]  : Data to be bypassed with timing alignment
- in_1_flat[N*16]  : Data to be summed by the adder tree

Outputs:
- in_1_sum         : 16-bit result of the summation of in_1_flat
- valid_bypass_out : Valid signal delayed to match in_1_sum
- in_bypass_flat   : Time-aligned copy of in_0_flat for later use
*/

module add_tree #(
    parameter N = 8
) (
    input clk,
    input en,
    input rst,

    input valid_in,
    input [N*16-1:0] in_0_flat,
    input [N*16-1:0] in_1_flat,

    output [15:0] in_1_sum,

    output valid_bypass_out,
    output [N*16-1:0] in_bypass_flat
);

    localparam STAGE = $clog2(N);

    wire [15:0] stage_data [0:STAGE][0:N-1];

    reg [STAGE*2-1:0] reg_valid_bypass;
    reg [N*16-1:0] reg_bypass [0:STAGE*2-1];

    integer k;
    always @(posedge clk) begin
        if (rst) begin
            for (k = 0; k <= STAGE*2-1; k = k + 1) begin
                reg_valid_bypass[k] <= 1'b0;
                reg_bypass[k] <= {N{16'd0}};
            end
        end
        else if (en) begin
            reg_valid_bypass[0] <= valid_in;
            reg_bypass[0] <= in_0_flat;
            for (k = 0; k <= STAGE*2-2; k = k + 1) begin
                reg_valid_bypass[k+1] <= reg_valid_bypass[k];
                reg_bypass[k+1] <= reg_bypass[k];
            end
        end
    end

    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin
            assign stage_data[0][i] = in_1_flat[i*16 +: 16];
        end
    endgenerate
    
    generate
        for (j = 0; j < STAGE; j = j + 1) begin : stages
            for (i = 0; i < (N >> (j+1)); i = i + 1) begin : adders
                add_FX16 ADD (
                    .A(stage_data[j][2*i]),
                    .B(stage_data[j][2*i+1]),
                    .CLK(clk),
                    .CE(en),
                    .S(stage_data[j+1][i])
                );
            end
        end
    endgenerate

    assign in_1_sum = stage_data[STAGE][0];

    assign valid_bypass_out = reg_valid_bypass[STAGE*2-1];
    assign in_bypass_flat = reg_bypass[STAGE*2-1];
endmodule