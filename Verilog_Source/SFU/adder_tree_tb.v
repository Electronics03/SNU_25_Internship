`timescale 1ns/1ps

module add_tree_tb;

    parameter N = 8;

    reg clk;
    reg rst;
    reg [N*16-1:0] in_flat;
    wire [15:0] out;

    add_tree #(.N(N)) DUT (
        .clk(clk),
        .rst(rst),
        .in_flat(in_flat),
        .out(out)
    );

    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz

    reg [15:0] in_arr [0:N-1];
    integer i;

    initial begin
        $display("---- Starting add_tree_module TB ----");

        // Initialize input FP16 values
        in_arr[0] = 16'h3C00; // 1.0
        in_arr[1] = 16'h4000; // 2.0
        in_arr[2] = 16'h4200; // 3.0
        in_arr[3] = 16'h4400; // 4.0
        in_arr[4] = 16'h4580; // 5.0
        in_arr[5] = 16'h46A0; // 6.0
        in_arr[6] = 16'h47C0; // 7.0
        in_arr[7] = 16'h48E0; // 8.0

        // Initialize signals
        rst = 0;
        in_flat = 0;
        #20;
        rst = 1;
        #10;

        // Pack inputs into flat bus
        in_flat = 0;
        for (i = 0; i < N; i = i + 1) begin
            in_flat = in_flat | (in_arr[i] << (i*16));
        end

        $display("[TB] Input vector loaded at time %0t", $time);

        // Wait for pipeline latency (rough estimate, adjust if needed)
        #500;

        $display("---- Simulation Complete ----");
        $finish;
    end

    // Monitor output
    always @(posedge clk) begin
        if (rst) begin
            $display("Time=%0t ns | Adder Tree OUT = %h", $time, out);
        end
    end

endmodule
