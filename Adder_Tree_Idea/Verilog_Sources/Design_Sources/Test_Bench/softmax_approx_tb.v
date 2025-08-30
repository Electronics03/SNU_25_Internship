`timescale 1ns/1ps

module softmax_tb;

    localparam [1023:0] my_x_0 = {8{16'h061D, 16'h061D, 16'hFDE2, 16'h0B13, 16'hFBCF, 16'h0B26, 16'h042B, 16'hF5BE}};
    localparam [1023:0] my_x_1 = {8{16'hFA60, 16'h042D, 16'hFFBF, 16'hF46A, 16'h0A79, 16'hF8B9, 16'hFBCC, 16'hF55D}};
    localparam [1023:0] my_x_2 = {8{16'h00F7, 16'h0AC0, 16'h0A99, 16'h09D6, 16'hFF4D, 16'hF72D, 16'hFF90, 16'h0B2A}};

    reg clk;
    reg en;
    reg rst;

    reg valid_in;
    reg [1:0] length_mode;

    initial clk = 0;
    always #5 clk = ~clk;

    reg signed [1023:0] in_x_flat;
    wire signed [1023:0] prob_flat;

    wire [15:0] in_x_arr [0:63];
    wire [15:0] prob_arr [0:63];
    wire valid_out;

    genvar idx;
    generate
        for (idx = 0; idx < 64; idx = idx + 1) begin
            assign in_x_arr[idx] = in_x_flat[16*idx +: 16];
            assign prob_arr[idx] = prob_flat[16*idx +: 16];
        end
    endgenerate

    softmax_approx DUT (
        .valid_in(valid_in),
        .in_x_flat(in_x_flat),
        .prob_flat(prob_flat),
        .length_mode(length_mode),
        .clk(clk),
        .rst(rst),
        .en(en),
        .valid_out(valid_out)
    );

    task display_fixed;
        input [15:0] val;
        real real_val;
        begin
            real_val = $itor($signed(val)) / 256.0;
            $display("%h = %f", val, real_val);
        end
    endtask

    initial begin
        in_x_flat = 0;
        valid_in = 0;
        #2; rst = 1;
        #10; rst = 0;
        #10; en = 1; 

        #10;
        in_x_flat = my_x_0; valid_in = 1; length_mode = 0;
        #10;
        in_x_flat = my_x_1; valid_in = 1; length_mode = 0;
        #10;
        in_x_flat = my_x_2; valid_in = 1; length_mode = 0;
        #10;
        in_x_flat = my_x_0; valid_in = 1; length_mode = 1;
        #10;
        in_x_flat = my_x_1; valid_in = 1; length_mode = 1;
        #10; 
        in_x_flat = my_x_2; valid_in = 1; length_mode = 1;
        #10;
        in_x_flat = my_x_0; valid_in = 1; length_mode = 2;
        #10;
        in_x_flat = my_x_1; valid_in = 1; length_mode = 2;
        #10;
        in_x_flat = my_x_2; valid_in = 1; length_mode = 2;
        #400;
        $finish;
    end

endmodule
