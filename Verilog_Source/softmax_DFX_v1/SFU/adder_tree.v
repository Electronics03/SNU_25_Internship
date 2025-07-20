module add_tree #(
    parameter N = 64
)(
    input clk,
    input rst,
    input ready,
    input [N*16-1:0] in_flat,
    output valid,
    output [15:0] out
);
    localparam STAGE = $clog2(N);


    wire [15:0] stage_data [0:STAGE][0:N-1];
    wire [N-1:0] stage_valid [0:STAGE];
    assign stage_valid[0] = {N{ready}};

    genvar i, j;

    generate
        for (i = 0; i < N; i = i + 1) begin
            assign stage_data[0][i] = in_flat[i*16 +: 16];
        end
    endgenerate
    
    generate
        for (j = 0; j < STAGE; j = j + 1) begin : stages
            for (i = 0; i < (N >> (j+1)); i = i + 1) begin : adders
                add_FP16 ADD (
                    .aclk(clk),
                    .aresetn(rst),
                    .s_axis_a_tvalid(stage_valid[j][2*i]),
                    .s_axis_a_tready(),
                    .s_axis_a_tdata(stage_data[j][2*i]),
                    .s_axis_b_tvalid(stage_valid[j][2*i+1]),
                    .s_axis_b_tready(),
                    .s_axis_b_tdata(stage_data[j][2*i+1]),
                    .m_axis_result_tvalid(stage_valid[j+1][i]),
                    .m_axis_result_tready(2'b1),
                    .m_axis_result_tdata(stage_data[j+1][i])
                );
            end
        end
    endgenerate

    assign valid = stage_valid[STAGE];
    assign out = stage_data[STAGE][0];

endmodule