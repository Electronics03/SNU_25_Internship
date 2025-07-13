module exp_module #(
    parameter N=4
)(
    input [N*16-1:0] exp_in_flat,
    input clk,
    input rst,
    input [N-1:0] in_tvalid,
    output [N-1:0] in_tready,
    output [N-1:0] out_tvalid,
    output [N*16-1:0] exp_out_flat
);
    wire [15:0] exp_in [0:N-1];
    wire [15:0] exp_out [0:N-1];

    genvar i;

    generate
        for (i = 0; i < N; i = i + 1) begin
            assign exp_in[i] = exp_in_flat[i*16 +: 16];
            assign exp_out_flat[i*16 +: 16] = exp_out[i];
        end
    endgenerate

    generate
        for (i = 0 ; i < N; i = i + 1) begin
            exp_FP16 EXP(
                .aclk(clk),
                .aresetn(rst),
                .s_axis_a_tvalid(in_tvalid[i]),
                .s_axis_a_tready(in_tready[i]),
                .s_axis_a_tdata(exp_in[i]),
                .m_axis_result_tvalid(out_tvalid[i]),
                .m_axis_result_tready(1'b1),
                .m_axis_result_tdata(exp_out[i])
            );
        end
    endgenerate
endmodule