`timescale 1ns/1ps

module add_tree_64_tb;

    reg clk;
    reg en;
    reg rst;

    reg [1:0] length_mode;

    reg valid_in;
    reg [1023:0] in_0_flat;
    reg [1023:0] in_1_flat;

    wire [15:0] in_1_sum_64_0;

    wire [15:0] in_1_sum_32_0;
    wire [15:0] in_1_sum_32_1;

    wire [15:0] in_1_sum_16_0;
    wire [15:0] in_1_sum_16_1;
    wire [15:0] in_1_sum_16_2;
    wire [15:0] in_1_sum_16_3;

    wire [1:0] length_mode_bypass;
    wire valid_bypass_out;
    wire [1023:0] in_bypass_flat;

    add_tree_64 DUT (
        .clk(clk),
        .en(en),
        .rst(rst),

        .length_mode(length_mode),

        .valid_in(valid_in),
        .in_0_flat(in_0_flat),
        .in_1_flat(in_1_flat),

        .in_1_sum_64_0(in_1_sum_64_0),

        .in_1_sum_32_0(in_1_sum_32_0),
        .in_1_sum_32_1(in_1_sum_32_1),

        .in_1_sum_16_0(in_1_sum_16_0),
        .in_1_sum_16_1(in_1_sum_16_1),
        .in_1_sum_16_2(in_1_sum_16_2),
        .in_1_sum_16_3(in_1_sum_16_3),

        .length_mode_bypass(length_mode_bypass),
        .valid_bypass_out(valid_bypass_out),
        .in_bypass_flat(in_bypass_flat)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    reg [15:0] in_arr [0:63];

    integer i;

    initial begin
        $display("---- Starting add_tree_module TB ----");
        rst = 1;
        en = 0;

        in_1_flat = 0;
        in_0_flat = 16'd23;
        
        for (i = 0; i < 64; i = i + 1) begin
            in_arr[i] = i;
        end

        for (i = 0; i < 64; i = i + 1) begin
            in_1_flat = in_1_flat | (in_arr[i] << (i*16));
        end

        #10;
        rst = 0;
        en = 1;
        valid_in = 1;
        length_mode = 2'b10;
        #10;
        
        $display("[TB] reg vector loaded at time %0t", $time);
        #500;
        $display("---- Simulation Complete ----");
        $finish;
    end

    always @(posedge clk) begin
        if (rst) begin
            $display("Time=%0t ns | Adder Tree OUT = %h", $time, in_1_sum_64_0);
        end
    end
endmodule
