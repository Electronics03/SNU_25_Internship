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

    // 클록 생성
    initial clk = 0;
    always #5 clk = ~clk;

    // DUT 인스턴스
    VFU #(.N(N)) DUT (
        .vect_A(vect_A),
        .vect_B(vect_B),
        .INST(INST),
        .clk(clk),
        .rst(rst),
        .vect_out_flat(vect_out_flat),
        .out_tvalid(out_tvalid)
    );

    // 테스트 입력 데이터
    reg [15:0] A_arr [0:N-1];
    reg [15:0] B_arr [0:N-1];
    reg [15:0] OUT_arr [0:N-1];

    integer i;

    initial begin
        // 초기화
        rst = 0;
        INST = 2'b00;
        vect_A = 0;
        vect_B = 0;

        // FP16 상수 예제값
        A_arr[0] = 16'h3C00; // 1.0
        A_arr[1] = 16'h4000; // 2.0
        A_arr[2] = 16'h4200; // 3.0
        A_arr[3] = 16'h4400; // 4.0

        B_arr[0] = 16'h3800; // 0.5
        B_arr[1] = 16'h3800;
        B_arr[2] = 16'h3800;
        B_arr[3] = 16'h3800;

        // 클록 두어 싸이클 대기
        #10;

        // 리셋 활성
        rst = 0;
        #20;
        rst = 1;
        #20;

        // ---------------------------------------
        // 첫 INST : MULT
        // ---------------------------------------
        INST = 2'b00;
        $display("[TB] INST = MULT (00)");

        pack_inputs();

        #100;

        // ---------------------------------------
        // 두 번째 INST : ADD
        // ---------------------------------------
        INST = 2'b01;
        $display("[TB] INST = ADD (01)");

        #100;

        // ---------------------------------------
        // 세 번째 INST : SUB+EXP
        // ---------------------------------------
        INST = 2'b10;
        $display("[TB] INST = SUB+EXP (10)");

        #200;

        // ---------------------------------------
        // 네 번째 INST : BYPASS
        // ---------------------------------------
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
