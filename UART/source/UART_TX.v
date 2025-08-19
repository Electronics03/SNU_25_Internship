module UART_TX(
    input UART_clk,
    input [7:0] din,
    input start,
    input rst,
    output reg tx_data
    );
    
    localparam IDEL = 4'd0; 
    localparam START = 4'd1;
    localparam ST2 = 4'd2;
    localparam ST3 = 4'd3;
    localparam ST4 = 4'd4;
    localparam ST5 = 4'd5;
    localparam ST6 = 4'd6;
    localparam ST7 = 4'd7;
    localparam ST8 = 4'd8;
    localparam ST9 = 4'd9;
    localparam STOP = 4'd10;
    
    (*keep="true"*) reg [3:0] state;

    always @(posedge UART_clk) begin
        if (rst) begin
            state <= IDEL;
        end
        else begin
            case (state)
                IDEL : if(start==1) state <= START;
                    else state <= IDEL;
                START  : state <= ST2;
                ST2  : state <= ST3;
                ST3  : state <= ST4;
                ST4  : state <= ST5;
                ST5  : state <= ST6;
                ST6  : state <= ST7;
                ST7  : state <= ST8;
                ST8  : state <= ST9;
                ST9  : state <= STOP;
                STOP : state <= IDEL;
                default : state <= IDEL;
            endcase
        end
    end

    always @(posedge UART_clk) begin
        if (rst) begin
            tx_data <= 1;
        end
        else begin
            case (state)
                IDEL  : tx_data <= 1; 
                START : tx_data <= 0;
                ST2   : tx_data <= din[0];
                ST3   : tx_data <= din[1];
                ST4   : tx_data <= din[2];
                ST5   : tx_data <= din[3];
                ST6   : tx_data <= din[4];
                ST7   : tx_data <= din[5];
                ST8   : tx_data <= din[6];
                ST9   : tx_data <= din[7];
                STOP  : tx_data <= 1;
                default: tx_data <= 1; 
            endcase
        end
    end

endmodule