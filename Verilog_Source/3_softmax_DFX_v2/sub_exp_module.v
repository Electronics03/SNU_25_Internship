module sub_exp_module #(
    parameter N = 64
) (
    input clk,
    input [N-1:0] valid_in_A,
    input [N-1:0] valid_in_B,
    input [N-1:0] tlast_in,
    input [N-1:0] ready_out,
    input [N*16-1:0] sub_in_A_flat,
    input [N*16-1:0] sub_in_B_flat,
    output [N-1:0] valid_out,
    output [N-1:0] tlast_out,
    output [N-1:0] ready_in_A,
    output [N-1:0] ready_in_B,
    output [N*16-1:0] sub_exp_out_flat
);
    wire [15:0] sub_A_in [0:N-1];
    wire [15:0] sub_B_in [0:N-1];

    wire [N-1:0] valid_sub_out;
    wire [N-1:0] tlast_sub_out;
    wire [15:0] sub_out [0:N-1];

    wire [N-1:0] ready_exp_in;
    wire [N-1:0] valid_exp_in;

    wire [15:0] sub_exp_out [0:N-1];

    genvar i;

    generate
        for (i = 0; i < N; i = i + 1) begin
            assign sub_A_in[i] = sub_in_A_flat[i*16 +: 16];
            assign sub_B_in[i] = sub_in_B_flat[i*16 +: 16];
            assign sub_exp_out_flat[i*16 +: 16] = sub_exp_out[i];
        end
    endgenerate

    generate
        for (i = 0 ; i < N; i = i + 1) begin
            sub_FP16 SUB (
                .aclk(clk),
                .s_axis_a_tvalid(valid_in_A[i]),
                .s_axis_a_tready(ready_in_A[i]),
                .s_axis_a_tdata(sub_A_in[i]),
                .s_axis_a_tlast(tlast_in[i]),
                .s_axis_b_tvalid(valid_in_B[i]),
                .s_axis_b_tready(ready_in_B[i]),
                .s_axis_b_tdata(sub_B_in[i]),
                .m_axis_result_tvalid(valid_sub_out[i]),
                .m_axis_result_tready(ready_exp_in[i]),
                .m_axis_result_tdata(sub_out[i]),
                .m_axis_result_tlast(tlast_sub_out[i])
            );
        end
    endgenerate

    generate
        for (i = 0 ; i < N; i = i + 1) begin
            exp_FP16 EXP (
                .aclk(clk),
                .s_axis_a_tvalid(valid_sub_out[i]),
                .s_axis_a_tready(ready_exp_in[i]),
                .s_axis_a_tdata(sub_out[i]),
                .s_axis_a_tlast(tlast_sub_out[i]),
                .m_axis_result_tvalid(valid_out[i]),
                .m_axis_result_tready(ready_out[i]),
                .m_axis_result_tdata(sub_exp_out[i]),
                .m_axis_result_tlast(tlast_out[i])
            );
        end
    endgenerate
endmodule