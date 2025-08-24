// Input 1024 bit data, and output 64 bit data sequentially

module shiftreg_1024_64(
    input wire clk,
    input wire rst_n,
    input wire [64*16-1:0] x_1024,
    input wire x_1024_valid, 
    input wire next_ready,
    output wire x_64_ready,
    output wire x_64_valid, 
    output wire [63:0] x_64 
    );
    
    wire data_receive;
    wire data_send;
    reg [64*16-1:0] x_1024_reg;
    reg [4:0] count16;
    
    assign data_receive=x_1024_valid & x_64_ready;
    assign data_send=x_64_valid & next_ready;

    always @(posedge clk) begin
        if(!rst_n) x_1024_reg <= 0;
        else if(data_receive) x_1024_reg <= x_1024;
        else if(data_send) x_1024_reg <= {64'd0, x_1024_reg[64*16-1 : 64]};
    end
    
    always @(posedge clk) begin
        if(!rst_n) count16 <= 0;
        else if(data_receive) count16 <= 16;
        else if(data_send && count16 > 5'd0) count16 <= count16-1;
    end
    
    assign x_64_ready = (count16 == 5'd0);
    assign x_64_valid = (count16 != 5'd0);
    assign x_64 = x_1024_reg[63:0];
endmodule
