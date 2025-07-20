`timescale 1ns/1ps

module softmax_tb;

    parameter N = 4;

    reg clk;
    reg rst;
    reg [N*16-1:0] vect_x_in;
    reg [N*16-1:0] vect_max_in;
    wire [N-1:0] in_tready;
    wire out_tvalid;
    wire [N*16-1:0] vect_out_flat;

    initial clk = 0;
    always #5 clk = ~clk;

    softmax #(.N(N)) DUT (
        .vect_x_in(vect_x_in),
        .vect_max_in(vect_max_in),
        .clk(clk),
        .rst(rst),
        .vect_out_flat(vect_out_flat),
        .out_tvalid(out_tvalid)
    );

    reg [15:0] A_arr [0:N-1];
    reg [15:0] B_arr [0:N-1];
    reg [15:0] Result_arr [0:N-1];

    integer i;

    initial begin
        rst = 0;
        vect_x_in = 0;
        vect_max_in = 0;

        #2 rst = 0;
        #10 rst = 1;
        #10;

        A_arr[0] = 16'h3C00; // 1.0
        A_arr[1] = 16'h4000; // 2.0
        A_arr[2] = 16'h4200; // 3.0
        A_arr[3] = 16'h4400; // 4.0

        B_arr[0] = 16'h4400; // 4.0
        B_arr[1] = 16'h4400;
        B_arr[2] = 16'h4400;
        B_arr[3] = 16'h4400;

        for (i = 0; i < N; i = i + 1) begin
        vect_x_in = vect_x_in | (A_arr[i] << (i*16));
        vect_max_in = vect_max_in | (B_arr[i] << (i*16));
        end

        #1000;
        $finish;
    end

    // 출력 모니터
    always @(posedge clk) begin
        for (i = 0; i < N; i = i + 1) begin
        if (out_tvalid) begin
            Result_arr[i] = vect_out_flat[i*16 +:16];
            $display("Time=%0t ns | Channel %0d | FP16 HEX Result = %h", $time, i, Result_arr[i]);
        end
        end
    end

endmodule