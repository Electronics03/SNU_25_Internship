module max_tree #(
    parameter N = 64
)(
    input valid_in,
    input clk,
    input rst,
    input [N*16-1:0] in_flat,
    output valid_out,
    output [15:0] out,
    output [N*16-1:0]out_prop
);
    localparam STAGE = $clog2(N);

    wire [15:0] stage_data [0:STAGE][0:N-1];
    wire [N-1:0] stage_tvalid [0:STAGE];

    reg [N*16-1:0] pipe [0:STAGE-1];

    integer k;
    always @(posedge clk) begin
        if (rst) begin
            for (k = 0; k <= STAGE-1; k = k + 1) begin
                pipe[k] <= {N{16'd0}};
            end
        end
        else begin
            pipe[0] <= in_flat;
            for (k = 0; k <= STAGE-2; k = k + 1) begin
                pipe[k+1] <= pipe[k];
            end
        end
    end

    assign stage_tvalid[0] = {N{valid_in}};

    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin
            assign stage_data[0][i] = in_flat[i*16 +: 16];
        end
    endgenerate
    
    generate
        for (j = 0; j < STAGE; j = j + 1) begin : stages
            for (i = 0; i < (N >> (j+1)); i = i + 1) begin : comps
                max_comparator MAX(
                    .clk(clk),
                    .rst(rst),
                    .valid_A_in(stage_tvalid[j][2*i]),
                    .A_in(stage_data[j][2*i]),
                    .valid_B_in(stage_tvalid[j][2*i+1]),
                    .B_in(stage_data[j][2*i+1]),
                    .MAX_out(stage_data[j+1][i]),
                    .valid_out(stage_tvalid[j+1][i])
                );
            end
        end
    endgenerate

    assign out = stage_data[STAGE][0];
    assign valid_out = stage_tvalid[STAGE][0];
    assign out_prop = pipe[STAGE-1];
endmodule

module max_comparator (
    input clk,
    input rst,
    input valid_A_in,
    input signed [15:0] A_in,
    input valid_B_in,
    input signed [15:0] B_in,
    output reg signed [15:0] MAX_out,
    output reg valid_out
);
    always @(posedge clk) begin
        if (rst) begin
            MAX_out <= 16'd0;
            valid_out <= 1'b0;
        end 
        else begin
            MAX_out <= (A_in > B_in) ? A_in : B_in;
            valid_out <= valid_A_in & valid_B_in;
        end
    end
endmodule