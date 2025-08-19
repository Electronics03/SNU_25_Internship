module uart_top(
    input wire rxd,
    input wire clk,
    output wire txd
    );
    
    (*keep="true"*) wire clk_wire;
    (*keep="true"*) wire [7:0] data_wire;
    (*keep="true"*) wire done;
    
    baudrate_gen clock(.clk_in(clk), .clk_out(clk_wire));
    uart_rx rx(.clk(clk_wire), .rx_data(rxd), .dout(data_wire),.en(done));
    uart_tx tx(.clk(clk_wire), .din(data_wire),.start(done),.tx_data(txd));
    
endmodule