module sim_FSM #(parameter N = 8)(
    input clk,
    input rst,

    output reg en,
    output reg valid_in,
    output reg [N*16-1:0] in_x_flat
);
    reg [N*16-1:0] mem [0:2];

    initial begin
        mem[0] = {8{16'hFFE5, 16'h0030, 16'hFFFF, 16'hFFF4, 16'hFFEE, 16'hFFE7, 16'hFFC2, 16'hFFC9}};
        mem[1] = {N{16'hFFF}};
        mem[2] = {8{16'hFFFC, 16'hFFEC, 16'h0028, 16'h000D, 16'h0011, 16'h0015, 16'h0029, 16'hFFC6}};
    end

    parameter IDLE = 2'b00;
    parameter DATA0 = 2'b01;
    parameter DATA1 = 2'b10;
    parameter DATA2 = 2'b11;

    reg [1:0] state;
    reg [1:0] next_state;

    always @(*) begin
        case (state)
            IDLE: begin 
                next_state = DATA0;
                en = 0;
                valid_in = 0;
                in_x_flat = 0;
            end
            DATA0: begin 
                next_state = DATA1;
                en = 1;
                valid_in = 1;
                in_x_flat = mem[0];
            end
            DATA1: begin 
                next_state = DATA2;
                en = 1;
                valid_in = 1;
                in_x_flat = mem[1];
            end
            DATA2: begin 
                next_state = DATA0;
                en = 1;
                valid_in = 1;
                in_x_flat = mem[2];
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end


endmodule