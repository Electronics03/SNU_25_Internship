`timescale 1ns/1ps

module tb_uart_softmax_top;

  // ---------------- Parameters (Verilog-2001) ----------------
  parameter CLK_HZ   = 100000000;  // 100 MHz
  parameter BAUD     = 1000000;    // 1 Mbps (시뮬 가속)
  parameter N_BYTES  = 128;
  parameter BIT_CLKS = CLK_HZ/BAUD; // 100clk/bit @1Mbps

  // ---------------- DUT I/O ----------------
  reg  clk;
  reg  rst_n;
  reg  uart_rx_i;   // TB -> DUT
  wire uart_tx_o;   // DUT -> TB
  wire busy_o;

  // ---------------- Instantiate DUT ----------------
  // 주의: DUT가 SystemVerilog로 되어 있다면, TB는 .v, DUT는 .sv로 혼용 컴파일하십시오.
  uart_softmax_top #(
    .CLK_HZ (CLK_HZ),
    .BAUD   (BAUD)
  ) dut (
    .clk       (clk),
    .rst_n     (rst_n),
    .uart_rx_i (uart_rx_i),
    .uart_tx_o (uart_tx_o),
    .busy_o    (busy_o)
  );

  // ---------------- 100 MHz Clock ----------------
  initial clk = 1'b0;
  always #1 clk = ~clk;

  // ---------------- Payload (128 bytes = 1024 bits) ----------------
  // 주어진 256-hex 문자열을 그대로 MSB-first로 기술
  // 첫 전송 바이트(0x01)를 꺼내려면 [8*(127-idx) +: 8]로 추출하십시오.
  localparam [1024-1:0] PAYLOAD_1024 =
    1024'h013E00ADF93704F9F67B0A42FCC7FB37FE44FC0BFF9F06820761016D029206FFFFE9F5EF089307B0008C009DFD3CFD430962FE220142011FF4A1F97B036D011DFAF6F6B9067DFFA007ED019300DAFDFA047401CC003B0934F992FBCDF656FDA103E3FCE40004F4E808390238F7B6FF6702700425FE4F05EEF8C9F740F798FDDD;

  // 수신 버퍼
  reg [7:0] rx_bytes [0:N_BYTES-1];
  integer   rx_count;

  // ---------------- UART 드라이버 (8N1, LSB-first) ----------------
  task uart_drive_byte;
    input [7:0] b;
    integer k, i;
    begin
      // start
      uart_rx_i = 1'b0;
      for (k=0; k<BIT_CLKS; k=k+1) @(posedge clk);
      // 8 data bits (LSB first)
      for (i=0; i<8; i=i+1) begin
        uart_rx_i = b[i];
        for (k=0; k<BIT_CLKS; k=k+1) @(posedge clk);
      end
      // stop
      uart_rx_i = 1'b1;
      for (k=0; k<BIT_CLKS; k=k+1) @(posedge clk);
    end
  endtask

  // ---------------- UART 모니터 (DUT TX 캡처) ----------------
  task uart_capture_byte;
    output [7:0] b;
    integer k, i;
    begin
      // start bit 감지
      @(negedge uart_tx_o);
      // 스타트 중간 지점으로 이동
      for (k=0; k<(BIT_CLKS/2); k=k+1) @(posedge clk);
      // 8 data bits 샘플링 (각 비트 중간에서 샘플)
      b = 8'h00;
      for (i=0; i<8; i=i+1) begin
        for (k=0; k<BIT_CLKS; k=k+1) @(posedge clk);
        b[i] = uart_tx_o;
      end
      // stop bit 소모
      for (k=0; k<BIT_CLKS; k=k+1) @(posedge clk);
    end
  endtask

  // ---------------- Q6.10 → real 보기용 함수 ----------------
  function real q610_to_real;
    input [15:0] v;
    integer signed si;
    begin
      si = $signed(v);
      q610_to_real = si / 1024.0;
    end
  endfunction

  // ---------------- Test Sequence ----------------
  integer i;
  reg [7:0] b;
reg [15:0] w;

  initial begin
    uart_rx_i = 1'b1; // idle high
    rst_n     = 1'b0;
    rx_count  = 0;

    // 리셋
    repeat (20) @(posedge clk);
    rst_n = 1'b1;
    repeat (10) @(posedge clk);

    // 병렬 실행: (1) 송신, (2) 수신
    fork
      // (1) TB -> DUT (RX 선으로 128바이트 전송)
      begin
        for (i=0; i<N_BYTES; i=i+1) begin
          // PAYLOAD_1024는 MSB-first이므로 다음과 같이 추출
          // i=0 -> [8*127 +: 8] = 0x01, i=1 -> [8*126 +: 8] = 0x3E, ...
          b = PAYLOAD_1024[8*(N_BYTES-1-i) +: 8];
          uart_drive_byte(b);
        end
      end

      // (2) DUT -> TB (TX 선에서 128바이트 수신)
      begin
        rx_count = 0;
        while (rx_count < N_BYTES) begin
          uart_capture_byte(b);
          rx_bytes[rx_count] = b;
          rx_count = rx_count + 1;
        end
      end
    join

    // 수신 결과 HEX로 출력
    $write("RX HEX = ");
    for (i=0; i<N_BYTES; i=i+1) begin
      $write("%02X", rx_bytes[i]);
    end
    $display("");

    // 앞 8개 단어(Q6.10, 리틀엔디언 조합) 출력
    $display("First 8 words (Q6.10 -> real):");
    for (i=0; i<8; i=i+1) begin
      w = {rx_bytes[2*i+1], rx_bytes[2*i]}; // LO,HI 순서로 들어왔음을 가정
      $display("  y[%0d] = 0x%04h -> %f", i, w, q610_to_real(w));
    end

    // 여유 시간 후 종료
    repeat (1000) @(posedge clk);
    $finish;
  end

  // ---------------- Watchdog ----------------
  initial begin
    #100000000; // 100 ms
    $display("Timeout.");
    $finish;
  end

endmodule
