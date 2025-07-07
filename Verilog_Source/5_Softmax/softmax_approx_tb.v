`timescale 1ns/1ps

module softmax_tb;

    parameter N = 4;

    wire signed [N*16-1:0] in_x_flat;
    wire signed [15:0] max_x;
    wire signed [N*16-1:0] prob_flat;

    softmax #(.N(N)) DUT (
        .in_x_flat(in_x_flat),
        .max_x(max_x),
        .prob_flat(prob_flat)
    );

    task display_fixed;
        input [15:0] val;
        real real_val;
        begin
            real_val = $itor($signed(val)) / 4096.0;
            $display("%h = %f", val, real_val);
        end
    endtask

    integer i;

    wire signed [15:0] in_x_arr [0:N-1];
    wire signed [15:0] prob_arr [0:N-1];

    assign in_x_arr[0] = 16'hEC80;
    assign in_x_arr[1] = 16'hFE18;
    assign in_x_arr[2] = 16'h2771;
    assign in_x_arr[3] = 16'h15DB;

    assign max_x = 16'h2771;
    assign in_x_flat = {in_x_arr[3], in_x_arr[2], in_x_arr[1], in_x_arr[0]};

    assign prob_arr[0] = prob_flat[15:0];
    assign prob_arr[1] = prob_flat[31:16];
    assign prob_arr[2] = prob_flat[47:32];
    assign prob_arr[3] = prob_flat[63:48];

    initial begin
        #10;
        $display("===== Softmax Testbench Start =====");
        $display("Inputs:");
        for (i = 0; i < N; i = i + 1) begin
            display_fixed(in_x_arr[i]);
        end
        $display("max_x = "); display_fixed(max_x);
        $display("");
        $display("Softmax Outputs (Probabilities):");
        for (i = 0; i < N; i = i + 1) begin
            display_fixed(prob_arr[i]);
        end
        $display("===== Softmax Testbench End =====");
        $finish;
    end

endmodule
