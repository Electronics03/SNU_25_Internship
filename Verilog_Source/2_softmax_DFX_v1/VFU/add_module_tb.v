`timescale 1ns/1ps

module add_module_tb;

    parameter N = 4;

    reg clk;
    reg rst;
    reg [N*16-1:0] add_in_A_flat;
    reg [N*16-1:0] add_in_B_flat;
    reg [N-1:0] in_tvalid;
    wire [N-1:0] in_tready;
    wire [N-1:0] out_tvalid;
    wire [N*16-1:0] add_out_flat;

    initial clk = 0;
    always #5 clk = ~clk;

        add_module #(.N(N)) DUT (
        .add_in_A_flat(add_in_A_flat),
        .add_in_B_flat(add_in_B_flat),
        .clk(clk),
        .rst(rst),
        .in_tvalid(in_tvalid),
        .in_tready(in_tready),
        .out_tvalid(out_tvalid),
        .add_out_flat(add_out_flat)
    );

    reg [15:0] A_arr [0:N-1];
    reg [15:0] B_arr [0:N-1];
    reg [15:0] Result_arr [0:N-1];

    integer i;

    initial begin
        rst = 0;
        in_tvalid = 0;
        add_in_A_flat = 0;
        add_in_B_flat = 0;

        #2 rst = 0;
        #10 rst = 1;
        #10;

        A_arr[0] = 16'h3C00; // 1.0
        A_arr[1] = 16'h4000; // 2.0
        A_arr[2] = 16'h4200; // 3.0
        A_arr[3] = 16'h4400; // 4.0

        B_arr[0] = 16'h3800; // 0.5
        B_arr[1] = 16'h3800;
        B_arr[2] = 16'h3800;
        B_arr[3] = 16'h3800;

        for (i = 0; i < N; i = i + 1) begin
        add_in_A_flat = add_in_A_flat | (A_arr[i] << (i*16));
        add_in_B_flat = add_in_B_flat | (B_arr[i] << (i*16));
        end
        #10;
        in_tvalid = {N{1'b1}};
        #10;
        in_tvalid = {N{1'b0}};

        #500;
        $finish;
    end

    // 출력 모니터
    always @(posedge clk) begin
        for (i = 0; i < N; i = i + 1) begin
        if (out_tvalid[i]) begin
            Result_arr[i] = add_out_flat[i*16 +:16];
            $display("Time=%0t ns | Channel %0d | FP16 HEX Result = %h", $time, i, Result_arr[i]);
        end
        end
    end

endmodule
