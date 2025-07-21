`timescale 1ns/1ps

module adder_tree_tb;

    parameter N = 16;

    reg  clk;
    
    reg  [N-1:0] tvalid_in;
    wire [N-1:0] tready_in;
    reg  [N-1:0] tlast_in;
    reg  [N*16-1:0] tdata_in;

    wire tvalid_out;
    reg  tready_out;
    wire tlast_out;
    wire [15:0] tdata_out;

    adder_tree #(.N(N)) DUT (
        .clk(clk),

        .tvalid_in(tvalid_in),
        .tready_in(tready_in),
        .tlast_in(tlast_in),
        .tdata_in(tdata_in),

        .tvalid_out(tvalid_out),
        .tready_out(tready_out),
        .tlast_out(tlast_out),
        .tdata_out(tdata_out)
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

        tdata_in = 0;
        #20;

        tvalid_in = {N{1'b1}};
        tlast_in = {N{1'b1}};
        tready_out = 1'b1;

        tdata_in = 0;
        for (i = 0; i < N; i = i + 1) begin
            tdata_in = tdata_in | (in_arr[i] << (i*16));
        end

        #100
        in_arr[0] = 16'h3c00;  // 1.0
        in_arr[1] = 16'h3c00;  // 2.0
        in_arr[2] = 16'h3c00;  // 3.0
        in_arr[3] = 16'h3c00;  // 4.0
        in_arr[4] = 16'h3c00;  // 5.0
        in_arr[5] = 16'h3c00;  // 6.0
        in_arr[6] = 16'h3c00;  // 7.0
        in_arr[7] = 16'h3c00;  // 8.0
        in_arr[8] = 16'h3c00;  // 1.0
        in_arr[9] = 16'h3c00;  // 2.0
        in_arr[10] = 16'h3c00; // 3.0
        in_arr[11] = 16'h3c00; // 4.0
        in_arr[12] = 16'h3c00; // 5.0
        in_arr[13] = 16'h3c00; // 6.0
        in_arr[14] = 16'h3c00; // 7.0
        in_arr[15] = 16'h3c00; // 8.0

        for (i = 0; i < N; i = i + 1) begin
            tdata_in = tdata_in | (in_arr[i] << (i*16));
        end

        $display("[TB] reg vector loaded at time %0t", $time);
        #2000;
        $display("---- Simulation Complete ----");
    end

endmodule