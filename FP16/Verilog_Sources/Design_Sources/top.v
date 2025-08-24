
module top(
    input wire clk,
    input wire rst_n,
    input wire uart_rx_in,   // PC -> FPGA (UART RXD)
    output wire uart_tx_out // FPGA -> PC (UART TXD) 
    );

    
    wire wea;
    wire [11:0] addra;
    wire [63:0] dina;
    wire [11:0] addrb;
    wire [63:0] doutb;
    
    wire wea_by_softmax, wea_by_uart;
    wire [11:0] addra_by_softmax, addra_by_uart;
    wire [11:0] addrb_by_softmax, addrb_by_uart;
    wire [63:0] dina_by_softmax, dina_by_uart;


    
    reg en_softmax;
    wire pulse_out_softmax;
    reg en_uart_tx;
    wire pulse1_out_uart;
    wire pulse2_out_uart;
    reg [1:0] state;

    wire [7:0] case_num;
    

    assign wea=!en_softmax ? wea_by_uart : wea_by_softmax;
    assign addra=!en_softmax ? addra_by_uart : addra_by_softmax;
    assign addrb=!en_softmax ? addrb_by_uart : addrb_by_softmax;
    assign dina=!en_softmax ? dina_by_uart : dina_by_softmax;
    
    always @(posedge clk) begin
        if(!rst_n) begin
            state <= 0;
            en_softmax <= 0;
            en_uart_tx <= 0;
        end
        else begin
            case(state) 
                0: begin
                    if(pulse1_out_uart) begin
                        en_softmax <= 1;
                        state <= 1;
                    end
                end
                1: begin
                    if(pulse_out_softmax) begin
                        en_softmax <= 0;
                        state <= 2;
                    end
                end
                2: begin
                    en_uart_tx <= 1;
                    if(pulse2_out_uart) begin
                        en_uart_tx <= 0;
                        state <= 0;
                    end
                end
            endcase
        end
    end
    
    blk_dual_RAM u_dual_ram (
      .clka(clk),    // input wire clka
      .wea(wea),      // input wire [0 : 0] wea
      .addra(addra),  // input wire [11 : 0] addra
      .dina(dina),    // input wire [63 : 0] dina
      .clkb(clk),    // input wire clkb
      .addrb(addrb),  // input wire [11 : 0] addrb
      .doutb(doutb)  // output wire [63 : 0] doutb
    );
    
    softmax_fsm u_softmax_fsm(
        .clk(clk),
        .rst_n(rst_n),
        .en(en_softmax),
        .x_in(doutb),
        .addrb(addrb_by_softmax),
        .x_out(dina_by_softmax),
        .addra(addra_by_softmax),
        .wea(wea_by_softmax),
        .case_num(case_num),
        .pulse_out_softmax(pulse_out_softmax)
    );


    
    uart_fsm u_uart_fsm(
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx_in(uart_rx_in),
        .uart_tx_out(uart_tx_out),
        .en_tx(en_uart_tx),
        .pulse1_out_uart(pulse1_out_uart),
        .pulse2_out_uart(pulse2_out_uart),
        .x_in(doutb),
        .addrb(addrb_by_uart),
        .x_out(dina_by_uart),
        .addra(addra_by_uart),
        .wea(wea_by_uart),
        .case_num(case_num)
    );  
    
endmodule
