`timescale 1ns/1ps

module mult_module_tb;

    parameter N = 4;

    reg clk;
    reg rst;
    reg [N*16-1:0] mult_in_A_flat;
    reg [N*16-1:0] mult_in_B_flat;
    reg [N-1:0] in_tvalid;
    wire [N-1:0] in_tready;
    wire [N-1:0] out_tvalid;
    wire [N*16-1:0] mult_out_flat;

    initial clk = 0;
    always #5 clk = ~clk;

    mult_module #(.N(N)) DUT (
        .mult_in_A_flat(mult_in_A_flat),
        .mult_in_B_flat(mult_in_B_flat),
        .clk(clk),
        .rst(rst),
        .in_tvalid(in_tvalid),
        .in_tready(in_tready),
        .out_tvalid(out_tvalid),
        .mult_out_flat(mult_out_flat)
    );

    reg [15:0] A_arr [0:N-1];
    reg [15:0] B_arr [0:N-1];
    reg [15:0] Result_arr [0:N-1];

    integer i;
    reg [N-1:0] sent_flag;

    initial begin
        rst = 0;
        in_tvalid = 0;
        mult_in_A_flat = 0;
        mult_in_B_flat = 0;
        sent_flag = 0;

        #2 rst = 0;
        #20 rst = 1;

        A_arr[0] = 16'h3C00;
        A_arr[1] = 16'h4000;
        A_arr[2] = 16'h4200;
        A_arr[3] = 16'h4400;

        B_arr[0] = 16'h3800;
        B_arr[1] = 16'h3800;
        B_arr[2] = 16'h3800;
        B_arr[3] = 16'h3800;

        for (i = 0; i < N; i = i + 1) begin
        mult_in_A_flat = mult_in_A_flat | (A_arr[i] << (i*16));
        mult_in_B_flat = mult_in_B_flat | (B_arr[i] << (i*16));
        end
    end

    always @(posedge clk) begin
        if (rst == 0) begin
        in_tvalid <= 0;
        sent_flag <= 0;
        end else begin
        for (i = 0; i < N; i = i + 1) begin
            if (in_tready[i] && !sent_flag[i]) begin
            in_tvalid[i] <= 1;
            sent_flag[i] <= 1;
            end else begin
            in_tvalid[i] <= 0;
            end
        end
        end
    end


    always @(posedge clk) begin
        for (i = 0; i < N; i = i + 1) begin
        if (out_tvalid[i]) begin
            Result_arr[i] = mult_out_flat[i*16 +:16];
            $display("Time=%0t ns | Channel %0d | FP16 HEX Result = %h", $time, i, Result_arr[i]);
        end
        end
    end

    initial begin
        #1000;
        $finish;
    end

endmodule