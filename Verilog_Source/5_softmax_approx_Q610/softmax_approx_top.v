module softmax_approx_top(
    input clk,
    input rst
);
    parameter N = 64;

    wire valid_in;
    wire [N*16-1:0] in_x_flat;
    wire en;
    wire valid_out;
    wire [N*16-1:0] prob_flat;

    softmax #(.N(N)) SOFTMAX(
        .valid_in(valid_in),
        .in_x_flat(in_x_flat),
        .clk(clk),
        .en(en),
        .rst(rst),
        .valid_out(valid_out),
        .prob_flat(prob_flat)
    );

    ila_0 ILA (
        .clk(clk),

        .probe0(clk),
        .probe1(rst),
        .probe2(valid_in),
        .probe3(in_x_flat),
        .probe4(en),
        .probe5(valid_out),
        .probe6(prob_flat)
    );

    sim_FSM #(.N(N)) FSM (
        .clk(clk),
        .rst(rst),
        .en(en),
        .valid_in(valid_in),
        .in_x_flat(in_x_flat)
    );

endmodule
