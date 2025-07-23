module fifo_delay #(
    parameter DELAY = 77,
    parameter N = 64
) (
    input clk,
    input rst,
    input [N*16-1:0] din,
    input valid_in,
    
    output reg [N*16-1:0] dout,
    output reg valid_out
);

    reg [N*16-1:0] mem [0:DELAY-1];
    reg [$clog2(DELAY)-1:0] wr_ptr, rd_ptr;
    reg [$clog2(DELAY+1):0] count;

    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            dout   <= 0;
            valid_out <= 0;
        end 
        else begin
            if (valid_in) begin
                mem[wr_ptr] <= din;

                wr_ptr <= (wr_ptr == DELAY-1) ? 0 : wr_ptr + 1;
                rd_ptr <= (rd_ptr == DELAY-1) ? 0 : rd_ptr + 1;

                if (count < DELAY) begin
                    count <= count + 1; 
                end

                dout <= mem[rd_ptr];
                valid_out <= (count >= DELAY);
            end 
            else begin
                valid_out <= 0;
            end
        end
    end
endmodule
