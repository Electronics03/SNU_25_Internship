module softmax #(
    parameter N = 8
)(
    input [N*16-1:0] vect_x_in,
    input [N*16-1:0] vect_max_in,
    input clk,
    input rst,
    output [N*16-1:0] vect_out_flat,
    output out_tvalid
);
    wire valid_s1, valid_s2;
    wire [N*16-1:0] vec_exp;
    wire [15:0] out;

    VFU #(.N(N)) S1 (
        .vect_A_in(vect_x_in),
        .vect_B_in(vect_max_in),
        .INST(2'b10),
        .clk(clk),
        .rst(rst),
        .vect_out_flat(vec_exp),
        .out_tvalid(valid_s1)
    );
    SFU #(.N(N)) S2 (
        .clk(clk),
        .rst(rst),
        .ready(valid_s1),
        .in_flat(vec_exp),
        .out(out),
        .valid(valid_s2)
    );
    VFU #(.N(N)) S3 (
        .vect_A_in({N{out}}),
        .vect_B_in(vec_exp),
        .INST(2'b00),
        .clk(clk),
        .rst(rst),
        .vect_out_flat(vect_out_flat),
        .out_tvalid(out_tvalid)
    );

endmodule