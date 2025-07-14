`timescale 1ns/1ps

module VFU_tb;

    parameter N = 4;

    reg clk;
    reg rst;
    reg [N*16-1:0] vect_A;
    reg [N*16-1:0] vect_B;
    reg [1:0] INST;

    wire [N*16-1:0] vect_out_flat;
    wire out_tvalid;

    initial clk = 0;
    always #5 clk = ~clk;

    VFU #(.N(N)) DUT (
        .vect_A_in(vect_A),
        .vect_B_in(vect_B),
        .INST(INST),
        .clk(clk),
        .rst(rst),
        .vect_out_flat(vect_out_flat),
        .out_tvalid(out_tvalid)
    );

    reg [15:0] A_arr [0:N-1];
    reg [15:0] B_arr [0:N-1];
    reg [15:0] OUT_arr [0:N-1];

    integer i;

    initial begin
        rst = 0;
        INST = 2'b00;
        vect_A = 0;
        vect_B = 0;

        A_arr[0] = 16'h3C00; // 1.0
        A_arr[1] = 16'h4000; // 2.0
        A_arr[2] = 16'h4200; // 3.0
        A_arr[3] = 16'h4400; // 4.0

        B_arr[0] = 16'h3800; // 0.5
        B_arr[1] = 16'h3800;
        B_arr[2] = 16'h3800;
        B_arr[3] = 16'h3800;

        #10;

        rst = 0;
        #20;
        rst = 1;
        #20;

        INST = 2'b00;
        $display("[TB] INST = MULT (00)");

        pack_inputs();

        #200;
        INST = 2'b01;
        $display("[TB] INST = ADD (01)");

        #100;
        INST = 2'b10;
        $display("[TB] INST = SUB+EXP (10)");

        #200;
        INST = 2'b11;
        $display("[TB] INST = BYPASS (11)");

        #100;

        $finish;
    end

    task pack_inputs;
        begin
            vect_A = 0;
            vect_B = 0;
            for (i = 0; i < N; i = i + 1) begin
                vect_A = vect_A | (A_arr[i] << (i*16));
                vect_B = vect_B | (B_arr[i] << (i*16));
            end
        end
    endtask

    always @(posedge clk) begin
        if (out_tvalid) begin
            $display("Time=%0t ns | INST=%b | OUT_TVALID=1", $time, INST);
            for (i = 0; i < N; i = i + 1) begin
                OUT_arr[i] = vect_out_flat[i*16 +:16];
                $display("  Channel %0d : FP16 HEX = %h", i, OUT_arr[i]);
            end
        end
    end

endmodule
