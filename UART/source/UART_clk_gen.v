module baudrate_gen(
    input wire clk,
    output reg clk_out
);
    (*keep="true"*) reg [27:0] counter = 28'b0;
    
    always @(posedge clk)begin
        if(counter == 867)   
            counter <= 28'b0;
        else 
            counter <= counter + 1;
    end

    always @(posedge clk) begin
        if(counter == 0)
            clk_out <= 1'b0;
        else if(counter == 434)
            clk_out <= ~clk_out;
        else if (counter == 867)
            clk_out <= ~clk_out;
        else   
            clk_out <= clk_out;
    end
endmodule