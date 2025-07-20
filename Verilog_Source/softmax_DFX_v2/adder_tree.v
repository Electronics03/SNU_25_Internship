module adder_tree #(
    parameter N = 64
) (
    input  clk,
    
    input  [N-1:0] tvalid_in,
    output [N-1:0] tready_in,
    input  [N-1:0] tlast_in,
    input  [N*16-1:0] tdata_in,

    output tvalid_out,
    input  tready_out,
    output tlast_out,
    output [15:0] tdata_out
);

    localparam STAGE = $clog2(N);
    
    wire [N-1:0] stage_tvalid [0:STAGE];
    wire [N-1:0] stage_tready [0:STAGE];
    wire [N-1:0] stage_tlast [0:STAGE];
    wire [15 :0] stage_tdata  [0:STAGE][0:N-1];

    assign stage_tvalid[0] = tvalid_in;
    assign tready_in = stage_tready[0];
    assign stage_tlast[0] = tlast_in;
    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin
            assign stage_tdata[0][i] = tdata_in[i*16 +: 16];
        end
    endgenerate
    
    generate
        for (j = 0; j < STAGE; j = j + 1) begin : stages
            for (i = 0; i < (N >> (j+1)); i = i + 1) begin : adders
                add_FP16 ADD (
                    .aclk(clk),
                    .s_axis_a_tvalid(stage_tvalid[j][2*i]),
                    .s_axis_a_tready(stage_tready[j][2*i]),
                    .s_axis_a_tlast(stage_tlast[j][2*i]), 
                    .s_axis_a_tdata(stage_tdata[j][2*i]),

                    .s_axis_b_tvalid(stage_tvalid[j][2*i+1]),
                    .s_axis_b_tready(stage_tready[j][2*i+1]),
                    .s_axis_b_tdata(stage_tdata[j][2*i+1]),

                    .m_axis_result_tvalid(stage_tvalid[j+1][i]),
                    .m_axis_result_tready(stage_tready[j+1][i]),
                    .m_axis_result_tdata(stage_tdata[j+1][i]),
                    .m_axis_result_tlast(stage_tlast[j+1][i]) 
                );
            end
        end
    endgenerate

    assign tvalid_out = stage_tvalid[STAGE][0];
    assign tdata_out  = stage_tdata[STAGE][0];
    assign tlast_out  = stage_tlast[STAGE][0];
    assign stage_tready[STAGE][0] = tready_out;

endmodule