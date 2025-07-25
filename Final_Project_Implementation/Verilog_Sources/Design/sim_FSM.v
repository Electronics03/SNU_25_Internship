module sim_FSM #(parameter N = 8)(
    input clk,
    input rst,

    output reg en,
    output reg valid_in,
    output reg [N*16-1:0] in_x_flat
);
    reg [N*16-1:0] mem [0:2];

    initial begin
        mem[0] = {8{16'h061D, 16'h061D, 16'hFDE2, 16'h0B13, 16'hFBCF, 16'h0B26, 16'h042B, 16'hF5BE}};
        mem[1] = {8{16'hFA60, 16'h042D, 16'hFFBF, 16'hF46A, 16'h0A79, 16'hF8B9, 16'hFBCC, 16'hF55D}};
        mem[2] = {8{16'h00F7, 16'h0AC0, 16'h0A99, 16'h09D6, 16'hFF4D, 16'hF72D, 16'hFF90, 16'h0B2A}};
    end

    localparam IDLE = 2'b00;
    localparam DATA0 = 2'b01;
    localparam DATA1 = 2'b10;
    localparam DATA2 = 2'b11;

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