module uart_block_rx_128 (
    input clk,
    input rst,
    input rxd,
    input consume,

    output reg block_ready,
    output reg [7:0] byte_count,
    output reg overrun,

    input [6:0] rd_addr,
    output [7:0] rd_data
);
    reg [7:0] mem [0:127];

    wire rx_done;
    wire [7:0] rx_byte;

    uart_rx u_rx (
        .clk(clk),
        .rst(rst),

        .Rx_Serial(rxd),

        .Rx_Done(rx_done),
        .Rx_Out(rx_byte)
    );

    assign rd_data = mem[rd_addr];

    reg [6:0] wr_ptr;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 7'd0;
            block_ready <= 1'b0;
            byte_count <= 8'd0;
            overrun <= 1'b0;
        end 
        else begin
            if (consume) begin
                wr_ptr <= 7'd0;
                block_ready <= 1'b0;
                byte_count <= 8'd0;
                overrun <= 1'b0;
            end
            if (rx_done) begin
                if (!block_ready) begin
                    mem[wr_ptr] <= rx_byte;
                    if (wr_ptr == 7'd127) begin
                        block_ready <= 1'b1;
                        byte_count <= 8'd128;
                    end 
                    else begin
                        wr_ptr <= wr_ptr + 7'd1;
                        byte_count <= byte_count + 8'd1;
                    end
                end 
                else begin
                    overrun <= 1'b1;
                end
            end
        end
    end
endmodule