module VFU #(
    parameter N = 64
)(
    input [N*16-1:0] vect_A,
    input [N*16-1:0] vect_B,
    input [1:0] INST,
    input clk,
    input rst,
    output reg [N*16-1:0] vect_out_flat,
    output reg out_tvalid
);
    localparam MULT_LAT = 11;
    localparam ADD_LAT = 6;
    localparam SUB_LAT = 11;
    localparam EXP_LAT = 6;
    localparam SUBEXP_LAT = SUB_LAT + EXP_LAT;
    localparam MAX_LAT = SUBEXP_LAT;

    reg [1:0] inst_pipe [0:MAX_LAT-1];
    integer i;

    always @(posedge clk) begin
        if (~rst) begin
            for (i = 0; i < MAX_LAT; i = i + 1)
                inst_pipe[i] <= 2'b00;
        end
        else begin
            inst_pipe[0] <= INST;
            for (i = 1; i < MAX_LAT; i = i + 1)
                inst_pipe[i] <= inst_pipe[i-1];
        end
    end

    wire [N*16-1:0] sub_result;
    wire [N*16-1:0] exp_result;
    wire [N*16-1:0] add_result;
    wire [N*16-1:0] mult_result;
    wire [N*16-1:0] bypass_result;

    wire mult_valid, add_valid, sub_valid, exp_valid;
    wire sub_exp_valid;

    assign bypass_result = vect_A;

    add_module #(.N(N)) ADDM (
        .add_in_A_flat(vect_A),
        .add_in_B_flat(vect_B),
        .clk(clk),
        .rst(rst),
        .in_tvalid({N{1'b1}}),
        .in_tready(),
        .out_tvalid(add_valid),
        .add_out_flat(add_result)
    );

    mult_module #(.N(N)) MULTM (
        .mult_in_A_flat(vect_A),
        .mult_in_B_flat(vect_B),
        .clk(clk),
        .rst(rst),
        .in_tvalid({N{1'b1}}),
        .in_tready(),
        .out_tvalid(mult_valid),
        .mult_out_flat(mult_result)
    );

    sub_module #(.N(N)) SUBM (
        .sub_in_A_flat(vect_A),
        .sub_in_B_flat(vect_B),
        .clk(clk),
        .rst(rst),
        .in_tvalid({N{1'b1}}),
        .in_tready(),
        .out_tvalid(sub_valid),
        .sub_out_flat(sub_result)
    );

    exp_module #(.N(N)) EXPM (
        .exp_in_flat(sub_result),
        .clk(clk),
        .rst(rst),
        .in_tvalid({N{sub_valid}}),
        .in_tready(),
        .out_tvalid(exp_valid),
        .exp_out_flat(exp_result)
    );

    assign sub_exp_valid = exp_valid;

    always @(posedge clk) begin
        if (~rst) begin
            vect_out_flat <= 0;
            out_tvalid <= 0;
        end
        else begin
            out_tvalid <= 0;
            vect_out_flat <= 0;

            if (mult_valid && inst_pipe[MULT_LAT-1] == 2'b00) begin
                vect_out_flat <= mult_result;
                out_tvalid <= 1;
            end
            else if (add_valid && inst_pipe[ADD_LAT-1] == 2'b01) begin
                vect_out_flat <= add_result;
                out_tvalid <= 1;
            end
            else if (sub_exp_valid && inst_pipe[SUBEXP_LAT-1] == 2'b10) begin
                vect_out_flat <= exp_result;
                out_tvalid <= 1;
            end
            else if (inst_pipe[0] == 2'b11) begin
                vect_out_flat <= bypass_result;
                out_tvalid <= 1;
            end
        end
    end

endmodule
