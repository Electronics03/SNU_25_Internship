module UART_top(
    input wire rxd,
    input wire clk,
    input wire rst,
    output wire txd
);
    
    (*keep="true"*) wire clk_wire;
    (*keep="true"*) wire [7:0] data_wire;
    (*keep="true"*) wire done;
    
    baudrate_gen clock(.clk(clk), .clk_out(clk_wire));
    UART_RX rx(.UART_clk(clk_wire), .rx_data(rxd), .rst(rst), .data_out(data_wire), .en(done));
    UART_TX tx(.UART_clk(clk_wire), .din(data_wire), .rst(rst), .start(done), .tx_data(txd));
    
endmodule