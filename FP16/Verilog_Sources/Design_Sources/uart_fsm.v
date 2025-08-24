
module uart_fsm(
    input wire clk,
    input wire rst_n,
    input wire uart_rx_in,   // PC -> FPGA (UART RXD)
    output wire uart_tx_out, // FPGA -> PC (UART TXD)
    input wire en_tx,
    output reg pulse1_out_uart,
    output reg pulse2_out_uart,  
    input wire [63:0] x_in,
    output reg [11:0] addrb, //read
    output reg [63:0] x_out,
    output reg [11:0] addra, //write
    output reg wea,
    output reg [7:0] case_num
);

    wire [7:0] received_data;     
    wire received_data_pulse;     
    
    wire tx_done_pulse;         
    reg [3:0] count8;
    
    reg first_flag;
    reg end_flag1, end_flag2;
    
    parameter READ_64=2'd0,
              SEND_BYTE=2'd1;
    reg [7:0] out_byte;
    reg out_start;
    wire out_active;
     
    reg output_state;
    reg [4:0] x_out_idx; 
        
    uart_rx u_uart_rx (
        .clk(clk),
        .rst(~rst_n),            
        .baud_rate_select(3'b101),
        .Rx_Serial(uart_rx_in),   
        .Rx_Done(received_data_pulse), 
        .Rx_Out(received_data)   
    );
    always @(posedge clk) begin
        if(!rst_n) begin
            addra <= 0;
            x_out <= 0;
            wea <= 0;
            count8 <= 0;
            first_flag <= 0;
            case_num <= 0;
        end
        if(received_data_pulse) begin
            if(!first_flag) begin
                case_num <= received_data;
                first_flag <= 1;
            end
            else begin
                if(count8<8) begin
                    x_out <= {received_data, x_out[63:8]};
                    count8 <= count8+1;
                end
            end
        end
        else begin
            if(count8==8) begin
                wea <= 1;
                count8 <= count8 + 1;
            end
            else if(count8==9) begin
                wea <= 0;
                addra <= addra + 1;
                count8 <= 0;
            end
        end
    end
    always @(posedge clk) begin
        if(!rst_n) begin
            pulse1_out_uart <= 0;
            end_flag1 <= 0;
        end
        if((addra==case_num*16) && first_flag && !end_flag1) begin
            pulse1_out_uart <= 1;
            end_flag1 <= 1;
        end
        else pulse1_out_uart <= 0;         
    end

    
    uart_tx u_uart_tx (
        .clk(clk),
        .rst(~rst_n),           
        .baud_rate_select(3'b101),  
        .start(out_start), 
        .Byte_To_Send(out_byte), 
        .Tx_Active(out_active),     
        .Tx_Serial(uart_tx_out),      
        .Tx_Done(tx_done_pulse)     
    );
    always @(posedge clk) begin
        if (!rst_n) begin
            output_state <= READ_64;
            x_out_idx <= 0;
            addrb <= 1024;
            out_start <= 0;
            out_byte <= 0;
        end 
        else if(en_tx) begin
            case (output_state)
                READ_64: begin
                    out_byte <= x_in[7:0];
                    out_start <= 1;
                    x_out_idx <= x_out_idx + 1;
                    output_state <= SEND_BYTE;
                end

                SEND_BYTE: begin
                    if (x_out_idx < 8) begin
                        if(tx_done_pulse) begin
                            out_byte <= x_in[x_out_idx*8 +: 8];
                            out_start <= 1;
                            x_out_idx <= x_out_idx + 1;
                        end
                        else out_start <= 0;
                    end 
                    else if (x_out_idx == 8) begin
                        out_start <= 0;
                        addrb <= addrb + 1;
                        x_out_idx <= x_out_idx + 1;  
                    end
                    else if (x_out_idx ==9) begin
                        if(tx_done_pulse) begin
                            x_out_idx <= 0;
                            output_state <= READ_64;
                        end
                    end
                end
            endcase
        end
    end
    always @(posedge clk) begin
        if(!rst_n) begin
            pulse2_out_uart <= 0;
            end_flag2 <= 0;
        end
        if((addrb==case_num*16) && first_flag && !end_flag2) begin
            pulse2_out_uart <= 1;
            end_flag2 <= 1;
        end
        else pulse2_out_uart <= 0;         
    end
endmodule
