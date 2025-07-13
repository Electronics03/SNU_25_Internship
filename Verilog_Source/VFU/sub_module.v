module sub_module #(
    parameter N=4
)(
    input [N*16-1:0] sub_in_A_flat,
    input [N*16-1:0] sub_in_B_flat,
    input clk,
    input rst,
    input [N-1:0] in_tvalid,
    output [N-1:0] in_tready,
    output [N-1:0] out_tvalid,
    output [N*16-1:0] sub_out_flat
);
    wire [15:0] sub_A_in [0:N-1];
    wire [15:0] sub_B_in [0:N-1];
    wire [15:0] sub_out [0:N-1];

    genvar i;

    generate
        for (i = 0; i < N; i = i + 1) begin
            assign sub_A_in[i] = sub_in_A_flat[i*16 +: 16];
            assign sub_B_in[i] = sub_in_B_flat[i*16 +: 16];
            assign sub_out_flat[i*16 +: 16] = sub_out[i];
        end
    endgenerate

    generate
        for (i = 0 ; i < N; i = i + 1) begin
            sub_FP16 SUB(
                .aclk(clk),
                .aresetn(rst),
                .s_axis_a_tvalid(in_tvalid[i]),
                .s_axis_a_tready(in_tready[i]),
                .s_axis_a_tdata(sub_A_in[i]),
                .s_axis_b_tvalid(in_tvalid[i]),
                .s_axis_b_tready(in_tready[i]),
                .s_axis_b_tdata(sub_B_in[i]),
                .m_axis_result_tvalid(out_tvalid[i]),
                .m_axis_result_tready(1'b1),
                .m_axis_result_tdata(sub_out[i])
            );
        end
    endgenerate
endmodule