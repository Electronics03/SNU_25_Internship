module softmax #(parameter N = 8)(
    input valid_in,
    input [N*16-1:0] in_x_flat,
    input clk,
    input en,
    input rst,
    output valid_out,
    output [N*16-1:0] prob_flat
);
    wire [15:0] in_x [0:N-1];
    wire [15:0] prob [0:N-1];
    wire [N*16-1:0] max_prop_flat;
    wire [15:0] max_x;
    wire valid_max_out;

    wire [15:0] add_in [0:N-1];
    wire [15:0] y [0:N-1];
    wire [N*16-1:0] y_flat;
    wire [N*16-1:0] add_in_flat;
    wire [15:0] add_out;
    wire [N*16-1:0] add_out_prop_flat;
    wire [15:0] add_out_prop [0:N-1];

    wire [N-1:0] valid_s1_arr;
    wire [N-1:0] valid_s2_arr;

    wire valid_s1;
    wire valid_s2;

    assign valid_s1 = &(valid_s1_arr);
    assign valid_out = &(valid_s2_arr);

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin
            assign in_x[i] = max_prop_flat[i*16 +: 16];
            assign add_in_flat[i*16 +: 16] = add_in[i];
            assign y_flat[i*16 +: 16] = y[i];
            assign add_out_prop[i] = add_out_prop_flat[i*16 +: 16];
            assign prob_flat[i*16 +: 16] = prob[i];
        end
    endgenerate

    max_tree #(.N(N)) max_tree(
        .valid_in(valid_in),
        .clk(clk),
        .rst(rst),
        .in_flat(in_x_flat),
        .valid_out(valid_max_out),
        .out(max_x),
        .out_prop(max_prop_flat)
    );

    generate
        for (i = 0; i < N; i = i + 1) begin
            RU FIRSTSTAGE(
                .valid_in(valid_max_out),
                .in_0(max_x),
                .in_1(in_x[i]),
                .sel_mult(1'b1),
                .sel_mux(1'b1),
                .out_0(y[i]),
                .out_1(add_in[i]),
                .clk(clk),
                .rst(rst),
                .en(en),
                .valid_out(valid_s1_arr[i])
            );
        end
    endgenerate

    add_tree #(.N(N)) ADDT(
        .valid_in(valid_s1),
        .clk(clk),
        .rst(rst),
        .en(en),
        .in_0_flat(y_flat),
        .in_1_flat(add_in_flat),
        .out(add_out),
        .out_prop(add_out_prop_flat),
        .valid_out(valid_s2)
    );

    generate
        for (i = 0; i < N; i = i + 1) begin
            RU SECONDSTAGE(
                .valid_in(valid_s2),
                .in_0(add_out),
                .in_1(add_out_prop[i]),
                .sel_mult(1'b0),
                .sel_mux(1'b0),
                .out_0(),
                .out_1(prob[i]),
                .clk(clk),
                .rst(rst),
                .en(en),
                .valid_out(valid_s2_arr[i])
            );
        end
    endgenerate
endmodule