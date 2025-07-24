`timescale 1ns/1ps

module softmax_tb;

    parameter N = 8;

    localparam [N*16-1:0] my_x_0 = {
        16'b111111_10_0000_0000,
        16'b111110_00_1001_0000,
        16'b111111_01_0000_0000,
        16'b111110_10_0000_0000,
        16'b111111_01_0000_0000,
        16'b000000_00_0011_0000,
        16'b000011_10_0110_0010,
        16'b000000_00_1110_0000
    };

    localparam [N*16-1:0] my_x_1 = {N{16'b000011_10_0110_0010}};

    localparam [N*16-1:0] my_x_2 = {
        16'b111111_10_0000_0000,
        16'b111110_00_1001_0000,
        16'b111111_01_0000_0000,
        16'b111110_10_0000_0000,
        16'b111111_01_0000_0000,
        16'b000000_00_0011_0000,
        16'b000100_10_0110_0010,
        16'b111111_00_1110_0000
    };

    reg clk;
    reg en;
    reg rst;

    reg valid_in;

    initial clk = 0;
    always #5 clk = ~clk;

    reg signed [N*16-1:0] in_x_flat;
    wire signed [N*16-1:0] prob_flat;

    wire [15:0] in_x_arr [0:N-1];
    wire [15:0] prob_arr [0:N-1];
    wire valid_out;

    genvar idx;
    generate
        for (idx = 0; idx < N; idx = idx + 1) begin
            assign in_x_arr[idx] = in_x_flat[16*idx +: 16];
            assign prob_arr[idx] = prob_flat[16*idx +: 16];
        end
    endgenerate

    softmax #(.N(N)) DUT (
        .valid_in(valid_in),
        .in_x_flat(in_x_flat),
        .prob_flat(prob_flat),
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
        in_x_flat = my_x_0; valid_in = 1;
        #10;
        in_x_flat = my_x_1; valid_in = 1;
        #10;
        in_x_flat = my_x_2; valid_in = 1;
        #10;
        in_x_flat = my_x_0; valid_in = 1;
        #10;
        in_x_flat = my_x_1; valid_in = 1;
        #10;
        in_x_flat = my_x_2; valid_in = 1;
        #10;
        in_x_flat = my_x_0; valid_in = 1;
        #10;
        in_x_flat = my_x_1; valid_in = 1;
        #10;
        in_x_flat = my_x_2; valid_in = 1;
        #10;
        in_x_flat = my_x_0; valid_in = 1;
        #10;
        in_x_flat = my_x_1; valid_in = 1;
        #10;
        in_x_flat = my_x_2; valid_in = 1;
        #300;
        $finish;
    end

endmodule
