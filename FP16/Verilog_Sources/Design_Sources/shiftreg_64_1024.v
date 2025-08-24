// Input 64 bit data sequentailly, and output 1024 bit data

module shiftreg_64_1024(
    input wire clk,
    input wire rst_n,
    input wire [63:0] x_64,
    input wire x_64_valid, 
    input wire next_ready,
    output wire x_1024_ready,
    output wire x_1024_valid, 
    output wire [64*16-1:0] x_1024 
    );
    
    wire data_receive;
    wire data_send;
    reg [64*16-1:0] x_1024_reg;
    reg [4:0] count16;

    assign data_receive=x_64_valid & x_1024_ready;
    assign data_send=x_1024_valid & next_ready;
    
    always @(posedge clk) begin
        if(!rst_n) x_1024_reg <= 0;
        else if(data_receive) x_1024_reg <= {x_64, x_1024_reg[64*16-1 : 64]};
        else if(data_send) x_1024_reg <= 0;
    end
    
    always @(posedge clk) begin
        if(!rst_n) count16 <= 0;
        else if(data_receive && count16 < 5'd16) count16 <= count16+1;
        else if(data_send) count16 <= 0;
    end
    
    assign x_1024_ready = (count16 != 5'd16);
    assign x_1024_valid = (count16 == 5'd16);
    assign x_1024 = x_1024_reg;
endmodule
