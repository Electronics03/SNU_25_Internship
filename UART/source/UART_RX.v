module UART_RX (
    input UART_clk,
    input rst,
    input rx_data,

    output reg [7:0] data_out,
    output reg en
);
    (*keep="true"*) reg [1:0] state;
    (*keep="true"*) reg [4:0] counter;
    (*keep="true"*) reg [7:0] out_data;

    localparam IDEL = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;

    always @(posedge UART_clk) begin
        if (rst) begin
            state <= IDEL;
            counter <= 4'd0;
            out_data <= 8'd0;
            data_out <= 8'd0;
        end
        else begin
            case (state)
                IDEL: begin
                    if (rx_data==0) begin
                        state <= START;
                        counter <= 4'd0;
                        out_data <= out_data;
                        data_out <= data_out;
                        en <= 0;
                    end
                    else begin
                        state <= IDEL;
                        counter <= 4'd0;
                        out_data <= out_data;
                        data_out <= data_out;
                        en <= 0;
                    end
                end
                START: begin
                    state <= DATA;
                    counter <= 4'd1;
                    out_data[counter] <= rx_data;
                    data_out <= data_out;
                    en <= 0;
                end
                DATA: begin
                    if (counter==8) begin
                        state <= STOP;
                        counter <= 4'd0;
                        out_data <= out_data;
                        data_out <= data_out;
                        en <= 0;
                    end
                    else begin
                        state <= DATA;
                        counter <= counter + 1;
                        out_data[counter] <= rx_data;
                        data_out <= data_out;
                        en <= 0;
                    end
                end
                STOP: begin
                    state <= IDEL;
                    counter <= 4'd0;
                    out_data <= out_data;
                    data_out <= out_data;
                    en <= 1;
                end
                default: begin
                    state <= IDEL;
                    counter <= 4'd0;
                    out_data <= 8'd0;
                    data_out <= 8'd0;
                    en <= 0;
                end 
            endcase
        end
    end
endmodule