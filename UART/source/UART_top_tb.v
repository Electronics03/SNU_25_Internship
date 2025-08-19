`timescale 1ns/1ps

module UART_top_tb;

    reg clk;
    reg rx_data;
    wire txd;

    // DUT (Device Under Test)
    uart_top UUT(
    .rxd(rx_data),
    .clk(clk),
    .txd(txd)
);

    // 10ns 주기 (100MHz) 클럭
    initial clk = 0;
    always #5 clk = ~clk;

    localparam CLK_PERIOD = 10;              // ns
    localparam BAUD_RATE  = 115200;
    localparam BIT_TIME   = 1_000_000_000 / BAUD_RATE; // ns 단위 (약 8680ns)

    task UART_send;
        input [7:0] byte;
        integer i;
        begin
            // START bit
            rx_data = 0;
            #(BIT_TIME);

            // DATA bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx_data = byte[i];
                #(BIT_TIME);
            end

            // STOP bit
            rx_data = 1;
            #(BIT_TIME);
        end
    endtask


    initial begin
        // 초기화
        rx_data = 1; // idle = high
        #(10000);

        UART_send(8'hA5);
        #(50000);

        UART_send(8'h3C);
        #(50000);

        UART_send(8'h12);
        #(50000);

        UART_send(8'hA5);
        #(50000);

        UART_send(8'h3C);
        #(50000);

        UART_send(8'h12);
        #(50000);

        $finish;
    end
endmodule