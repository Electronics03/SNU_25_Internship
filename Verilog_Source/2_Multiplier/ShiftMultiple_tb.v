`timescale 1ns/1ps

module multiplier_shift_tb;

    parameter N = 8;
    reg clk;
    reg rst;
    reg en;
    reg [N-1:0] multiplicand;
    reg [N-1:0] multiplier;
    wire [(2*N)-1:0] product;

    Multiplier_shift #(N) uut (
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .clk(clk),
        .rst(rst),
        .en(en),
        .product(product)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("Simulation Start");
        rst = 1;
        en = 0;
        multiplicand = 0;
        multiplier = 0;
        #20;

        rst = 1;
        multiplicand = 8;
        multiplier = 3;
        #20;

        rst = 0;
        en = 1;
        repeat (N+1) @(posedge clk);
        en = 0;
        #20;
        $display("8 * 3 = %d", product);

        rst = 1; #10;
        multiplicand = 15;
        multiplier = 12;
        #20;

        rst = 0;
        en = 1;
        repeat (N+1) @(posedge clk);
        en = 0;

        #20;
        $display("15 * 12 = %d", product);

        rst = 1; #10;
        multiplicand = 25;
        multiplier = 0;
        #20;
        
        rst = 0;
        en = 1;
        repeat (N+1) @(posedge clk);
        en = 0;

        #20;
        $display("25 * 0 = %d", product);

        rst = 1; #10;
        multiplicand = 8'b00000000;
        multiplier = 8'b11111111;
        #20;
        rst = 0;
        en = 1;
        repeat (N+1) @(posedge clk);
        en = 0;

        #20;
        $display("11111111 * 0 = %d", product);
        $finish;
    end

endmodule
