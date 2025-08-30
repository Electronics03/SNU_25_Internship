`timescale 1ns/1ps

module max_tree_64_tb;

    reg clk;
    reg en;
    reg rst;

    reg [1:0] length_mode;

    reg [63:0] valid_in;
    reg [1023:0] in_flat;

    wire valid_MAX_out;

    wire [15:0] MAX_64_0;

    wire [15:0] MAX_32_0;
    wire [15:0] MAX_32_1;

    wire [15:0] MAX_16_0;
    wire [15:0] MAX_16_1;
    wire [15:0] MAX_16_2;
    wire [15:0] MAX_16_3;

    wire [1:0] length_mode_bypass;
    wire [63:0] valid_bypass_out;
    wire [1023:0] in_bypass;

    max_tree_64 DUT (
        .clk(clk),
        .en(en),
        .rst(rst),

        .length_mode(length_mode),

        .valid_in(valid_in),
        .in_flat(in_flat),

        .valid_MAX_out(valid_MAX_out),

        .MAX_64_0(MAX_64_0),

        .MAX_32_0(MAX_32_0),
        .MAX_32_1(MAX_32_1),

        .MAX_16_0(MAX_16_0),
        .MAX_16_1(MAX_16_1),
        .MAX_16_2(MAX_16_2),
        .MAX_16_3(MAX_16_3),

        .length_mode_bypass(length_mode_bypass),
        .valid_bypass_out(valid_bypass_out),
        .in_bypass(in_bypass)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    reg [15:0] in_arr [0:63];

    integer i;

    initial begin
        $display("---- Starting add_tree_module TB ----");
        rst = 1;
        en = 0;

        in_flat = 0;
        
        for (i = 0; i < 64; i = i + 1) begin
            in_arr[i] = i;
        end

        for (i = 0; i < 64; i = i + 1) begin
            in_flat = in_flat | (in_arr[i] << (i*16));
        end

        #10;
        rst = 0;
        en = 1;
        valid_in = 64'd18_446_744_073_709_551_615;
        length_mode = 2'b10;
        #10;
        
        $display("[TB] reg vector loaded at time %0t", $time);
        #500;
        $display("---- Simulation Complete ----");
        $finish;
    end

    always @(posedge clk) begin
        if (rst) begin
            $display("Time=%0t ns | Adder Tree OUT = %h", $time, MAX_64_0);
        end
    end
endmodule
