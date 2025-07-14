/*
16-bit fixed-point : Q4.12
Testbench for softmax module
Parameter : N (default 4)
Description:
- Applies 4 fixed-point test inputs with provided max_x for stability.
- Waits for evaluation and displays all inputs and resulting probabilities.
- Outputs are printed once in both hex and real-number formats.
*/

`timescale 1ns/1ps

module softmax_tb;

    parameter N = 4;

    reg clk;
    reg en;
    reg rst;

    reg valid_in;

    initial clk = 0;
    always #5 clk = ~clk;


    wire signed [N*16-1:0] in_x_flat;  // Flattened input vector
    wire signed [15:0] max_x;          // Maximum value for stabilization
    wire signed [N*16-1:0] prob_flat;  // Flattened output vector

    wire [N*16-1:0] add_in_flat_0;
    wire valid_out;

    // Instantiate softmax module
    softmax #(.N(N)) DUT (
        .valid_in(valid_in),
        .in_x_flat(in_x_flat),
        .max_x(max_x),
        .prob_flat(prob_flat),
        .add_in_flat_0(add_in_flat_0),
        .clk(clk),
        .rst(rst),
        .en(en),
        .valid_out(valid_out)
    );

    /*
    Task to display fixed-point Q4.12 value as hex and real
    */
    task display_fixed;
        input [15:0] val;
        real real_val;
        begin
            real_val = $itor($signed(val)) / 4096.0;
            $display("%h = %f", val, real_val);
        end
    endtask

    integer i;

    // Input and output unpacked arrays
    wire signed [15:0] in_x_arr [0:N-1];
    wire signed [15:0] prob_arr [0:N-1];

    // Define test inputs in Q4.12
    assign in_x_arr[0] = 16'hEC80;
    assign in_x_arr[1] = 16'hFE18;
    assign in_x_arr[2] = 16'h2771;
    assign in_x_arr[3] = 16'h15DB;

    // Provide max_x for numerical stability
    assign max_x = 16'h2771;

    // Flatten input array
    assign in_x_flat = {in_x_arr[3], in_x_arr[2], in_x_arr[1], in_x_arr[0]};

    // Unpack output probabilities
    assign prob_arr[0] = prob_flat[15:0];
    assign prob_arr[1] = prob_flat[31:16];
    assign prob_arr[2] = prob_flat[47:32];
    assign prob_arr[3] = prob_flat[63:48];

    /*
    Main stimulus:
    - Waits for module evaluation
    - Prints all inputs and resulting outputs once
    */
    initial begin
        #2; rst = 1;
        #10; rst = 0;
        #10; en = 1; valid_in = 1;

        $display("===== Softmax Testbench Start =====");
        #1000;
        $display("Inputs:");
        for (i = 0; i < N; i = i + 1) begin
            display_fixed(in_x_arr[i]);
        end

        $display("");
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
