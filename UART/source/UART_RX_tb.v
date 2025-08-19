`timescale 1ns/1ps

module UART_RX_tb;

    reg clk;
    wire UART_clk;
    reg rst;
    reg rx_data;
    wire [7:0] data_out;
    wire en;

    // DUT (Device Under Test)
    UART_RX uut (
        .UART_clk(UART_clk),
        .rst(rst),
        .rx_data(rx_data),
        .data_out(data_out),
        .en(en)
    );
    baudrate_gen b (
        .clk(clk),
        .clk_out(UART_clk)
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
        rst = 1;
        #(22311);
        rst = 0;

        UART_send(8'hA5);
        #(19232);

        UART_send(8'h3C);
        #(11231);

        UART_send(8'h12);
        #(32131);

        UART_send(8'hA5);
        #(12341);

        UART_send(8'h3C);
        #(63452);

        UART_send(8'h12);
        #(50000);

        $finish;
    end

    // 출력 모니터링
    initial begin
        $monitor("Time=%0t | en=%b data_out=0x%h",
                 $time, en, data_out);
    end

endmodule