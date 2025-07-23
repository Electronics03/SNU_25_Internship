module add_tree #(
    parameter N = 64
)(
    input clk,
    input rst,
    input en,
    input [N*16-1:0] in_0_flat,
    input [N*16-1:0] in_1_flat,
    output [15:0] out,
    output [N*16-1:0] out_prop
);
    localparam STAGE_NUM = $clog2(N);

    reg [N*16-1:0] pipe [0:STAGE_NUM-1];
    wire [15:0] stage_data [0:STAGE_NUM][0:N-1];
    wire [N-1:0] stage_valid [0:STAGE_NUM];

    integer k;
    always @(posedge clk) begin
        if (rst) begin
            for (k = 0; k <= STAGE_NUM-1; k = k + 1) begin
                pipe[k] <= N*16'd0;
            end
        end
        else if (en) begin
            pipe[0] <= in_0_flat;
            for (k = 0; k <= STAGE_NUM-2; k = k + 1) begin
                pipe[k+1] <= pipe[k];
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
        for (j = 0; j < STAGE_NUM; j = j + 1) begin : stages
            for (i = 0; i < (N >> (j+1)); i = i + 1) begin : adders
                add_FX16 ADD(
                    .A(stage_data[j][2*i]),
                    .B(stage_data[j][2*i+1]),
                    .CLK(clk),
                    .S(stage_data[j+1][i])
                );
            end
        end
    endgenerate

    assign out = stage_data[STAGE_NUM][0];
    assign out_prop = pipe[STAGE_NUM-1];
endmodule