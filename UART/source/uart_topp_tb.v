// Nexys A7 예시 Top: RX 받은 바이트를 즉시 TX로 에코 (Acco Top)
module acco_top (
    input  wire clk,     // 100 MHz
    input  wire rst,
    input  wire rxd,     // PC -> FPGA (USB-UART TXD -> FPGA RX)
    output wire txd      // FPGA -> PC (FPGA TX -> USB-UART RXD)
);
    // 115200 bps 선택 (귀 코드의 3'b101이 868클럭/비트에 해당)
    localparam [2:0] BAUD_SEL = 3'b101;

    // RX 쪽 신호
    wire        rx_done;
    wire [7:0]  rx_byte;

    // TX 쪽 신호
    wire        tx_active;
    wire        tx_done;
    reg         tx_start;     // 1클럭 펄스
    reg  [7:0]  tx_byte;

    // 전송 대기 플래그: 새 바이트를 받은 뒤 TX가 비면 1클럭 start
    reg         pend;

    // ---------------------------
    // UART 수신기
    // ---------------------------
    uart_rx u_rx (
        .clk              (clk),
        .baud_rate_select (BAUD_SEL),
        .Rx_Serial        (rxd),
        .Rx_Done          (rx_done),
        .Rx_Out           (rx_byte),
        .rst              (rst)
    );

    // ---------------------------
    // UART 송신기
    // ---------------------------
    uart_tx u_tx (
        .clk              (clk),
        .baud_rate_select (BAUD_SEL),
        .start            (tx_start),
        .Byte_To_Send     (tx_byte),
        .Tx_Active        (tx_active),
        .Tx_Serial        (txd),
        .Tx_Done          (tx_done),
        .rst              (rst)
    );

    // ---------------------------
    // RX→TX 에코 제어 (1바이트 버퍼링)
    // ---------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_start <= 1'b0;
            tx_byte  <= 8'd0;
            pend     <= 1'b0;
        end
        else begin
            // 기본값: start는 1클럭 펄스이므로 매 사이클 Low로 떨어뜨림
            tx_start <= 1'b0;

            // 새 바이트 수신 시 래치 + 보낼 것 보류
            if (rx_done) begin
                tx_byte <= rx_byte;
                pend    <= 1'b1;
            end

            // TX가 놀고 있고(pending이 있고) 그 순간 1클럭 start 펄스
            if (pend && !tx_active) begin
                tx_start <= 1'b1;  // 정확히 한 클럭만 High
                pend     <= 1'b0;
            end
        end
    end

endmodule
