module uart_rx (
    input clk,
    input rst,

    input Rx_Serial,

    output reg Rx_Done,
    output [7:0] Rx_Out
);

    reg Data_Received_R;
    reg Data_Received;

    reg [10:0] clk_count;
    reg [2:0] bit_index;
    reg [7:0] Data_Byte;

    reg [2:0] State;
    
    parameter baud_rate = 11'd391;

    parameter IDLE = 3'b000;
    parameter RX_START_BIT = 3'b001;
    parameter RX_DATA_BITS = 3'b010;
    parameter RX_STOP_BIT = 3'b011;
    parameter RESET = 3'b100;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            State <= IDLE;
            clk_count <= 11'd0;
            bit_index <= 3'd0;
            Data_Received <= 1'b0;
            Data_Received_R <= 1'b0;
            Rx_Done <= 1'b0;
            Data_Byte <= 8'd0;
        end 
        else begin
            Data_Received_R <= Rx_Serial;
            Data_Received <= Data_Received_R;
            case (State)
                IDLE: begin
                    Rx_Done <= 1'b0;
                    clk_count <= 11'd0;
                    bit_index <= 3'd0;

                    if (Data_Received == 1'b0) begin
                        State <= RX_START_BIT;
                    end
                    else  begin
                        State <= IDLE;
                    end
                end
                RX_START_BIT: begin
                    if (clk_count == ((baud_rate - 1'b1) >> 1)) begin
                        if (Data_Received == 1'b0) begin
                            clk_count <= 11'd0;
                            State <= RX_DATA_BITS;
                        end 
                        else begin
                            State <= IDLE;
                        end
                    end 
                    else begin
                        clk_count <= clk_count + 1'b1;
                        State <= RX_START_BIT;
                    end
                end
                RX_DATA_BITS: begin
                    if (clk_count < (baud_rate - 1'b1)) begin
                        clk_count <= clk_count + 1'b1;
                        State <= RX_DATA_BITS;
                    end else begin
                        clk_count <= 11'd0;
                        Data_Byte[bit_index] <= Data_Received;
                        if (bit_index == 3'b111) begin
                            bit_index <= 3'd0;
                            State <= RX_STOP_BIT;
                        end
                        else begin
                            bit_index <= bit_index + 1'b1;
                            State <= RX_DATA_BITS;
                        end
                    end
                end
                RX_STOP_BIT: begin
                    if (clk_count < (baud_rate - 1'b1)) begin
                        clk_count <= clk_count + 1'b1;
                        State <= RX_STOP_BIT;
                    end 
                    else begin
                        Rx_Done <= 1'b1;
                        clk_count <= 11'd0;
                        State <= RESET;
                    end
                end
                RESET: begin
                    State <= IDLE;
                    Rx_Done <= 1'b0;
                end
                default: State <= IDLE;
            endcase
        end
    end

    assign Rx_Out = Data_Byte;
endmodule