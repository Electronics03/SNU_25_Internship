`timescale 1ns/1ps

module SFU_tb;

    parameter N = 16;

    reg clk;
    reg rst;
    reg ready;
    reg [N*16-1:0] in_flat;
    wire [15:0] out;
    wire valid;

    SFU #(.N(N)) DUT (
        .clk(clk),
        .rst(rst),
        .ready(ready),
        .in_flat(in_flat),
        .out(out),
        .valid(valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    reg [15:0] in_arr [0:N-1];

    integer i;

    initial begin
        $display("---- Starting add_tree_module TB ----");

        in_arr[0] = 16'h3c00;  // 1.0
        in_arr[1] = 16'h4000;  // 2.0
        in_arr[2] = 16'h4200;  // 3.0
        in_arr[3] = 16'h4400;  // 4.0
        in_arr[4] = 16'h4500;  // 5.0
        in_arr[5] = 16'h4600;  // 6.0
        in_arr[6] = 16'h4700;  // 7.0
        in_arr[7] = 16'h4800;  // 8.0
        in_arr[8] = 16'h3C00;  // 1.0
        in_arr[9] = 16'h4000;  // 2.0
        in_arr[10] = 16'h4200; // 3.0
        in_arr[11] = 16'h4400; // 4.0
        in_arr[12] = 16'h4500; // 5.0
        in_arr[13] = 16'h4600; // 6.0
        in_arr[14] = 16'h4700; // 7.0
        in_arr[15] = 16'h4800; // 8.0

        rst = 0;
        in_flat = 0;
        #20;
        rst = 1;
        ready = 1;
        #10;

        in_flat = 0;
        for (i = 0; i < N; i = i + 1) begin
            in_flat = in_flat | (in_arr[i] << (i*16));
        end

        $display("[TB] Input vector loaded at time %0t", $time);
        #500;
        $display("---- Simulation Complete ----");
        $finish;
    end

    always @(posedge clk) begin
        if (rst) begin
            $display("Time=%0t ns | Adder Tree OUT = %h", $time, out);
        end
    end

endmodule
