module add_tree #(
    parameter N = 4
)(
    input clk,
    input rst,
    input [N*16-1:0] in_flat,
    output [15:0] out
);
    localparam STAGE_NUM = $clog2(N);


    wire [15:0] stage_data [0:STAGE_NUM][0:N-1];

    genvar i, j;

    generate
        for (i = 0; i < N; i = i + 1) begin
            assign stage_data[0][i] = in_flat[i*16 +: 16];
        end
    endgenerate
    
    generate
        for (j = 0; j < STAGE_NUM; j = j + 1) begin : stages
            for (i = 0; i < (N >> (j+1)); i = i + 1) begin : adders
                add_FP16 ADD (
                    .aclk(clk),
                    .aresetn(rst),
                    .s_axis_a_tvalid(1'b1),
                    .s_axis_a_tready(),
                    .s_axis_a_tdata(stage_data[j][2*i]),
                    .s_axis_b_tvalid(1'b1),
                    .s_axis_b_tready(),
                    .s_axis_b_tdata(stage_data[j][2*i+1]),
                    .m_axis_result_tvalid(),
                    .m_axis_result_tready(1'b1),
                    .m_axis_result_tdata(stage_data[j+1][i])
                );
            end
        end
    endgenerate

    assign out = stage_data[STAGE_NUM][0];

endmodule