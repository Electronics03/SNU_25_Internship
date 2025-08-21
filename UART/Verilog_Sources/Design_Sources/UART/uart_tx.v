module uart_tx (
    input clk,
    input rst,
    
    input start,
    input [7:0] Byte_To_Send,

    output Tx_Active,
    output reg Tx_Serial,
    output reg Tx_Done
);
    parameter baud_rate = 11'd391;
    parameter IDLE = 3'b000;
    parameter TX_START_BIT = 3'b001;
    parameter TX_DATA_BITS = 3'b010;
    parameter TX_STOP_BIT = 3'b011;
    parameter RESET = 3'b100;
    
    reg [2:0] State;
    reg [10:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] Data_Byte;
    reg Tx_Enable;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            State <= IDLE;
            clk_count <= 11'd0;
            bit_index <= 3'd0;
            Data_Byte <= 8'd0;
            Tx_Done <= 1'b0;
            Tx_Enable <= 1'b0;
        end else begin
            case (State)
                IDLE: begin
                    Tx_Serial <= 1'b1;
                    Tx_Done <= 1'b0;
                    clk_count <= 11'd0;
                    bit_index <= 3'd0;
                    if (start) begin
                        Tx_Enable <= 1'b1;
                        Data_Byte <= Byte_To_Send;
                        State <= TX_START_BIT;
                    end 
                    else begin
                        State <= IDLE;
                    end
                end
                TX_START_BIT: begin
                    Tx_Serial <= 1'b0;
                    if (clk_count < (baud_rate-1)) begin
                        clk_count <= clk_count + 1'b1;
                        State <= TX_START_BIT;
                    end 
                    else begin
                        clk_count <= 11'd0;
                        State <= TX_DATA_BITS;
                    end
                end
                TX_DATA_BITS: begin
                    Tx_Serial <= Data_Byte[bit_index];
                    if (clk_count < (baud_rate-1)) begin
                        clk_count <= clk_count + 1'b1;
                        State <= TX_DATA_BITS;
                    end 
                    else begin
                        clk_count <= 11'd0;
                        if (bit_index == 3'b111) begin
                            bit_index <= 3'd0;
                            State <= TX_STOP_BIT;
                        end 
                        else begin
                            bit_index <= bit_index + 1'b1;
                            State <= TX_DATA_BITS;
                        end
                    end
                end
                TX_STOP_BIT: begin
                    Tx_Serial <= 1'b1;
                    if (clk_count < (baud_rate-1)) begin
                        clk_count <= clk_count + 1'b1;
                        State <= TX_STOP_BIT;
                    end 
                    else begin
                        Tx_Done <= 1'b1;
                        clk_count <= 11'd0;
                        State <= RESET;
                        Tx_Enable <= 1'b0;
                    end
                end
                RESET: begin
                    Tx_Done <= 1'b0;
                    State <= IDLE;
                end
                default: State <= IDLE;
            endcase
        end
    end

    assign Tx_Active = Tx_Enable;
endmodule