module FSM #(
    parameter N = 64
)(
    input clk,
    output reg en,
    input rst,

    output [1023:0] data,
    output valid_in
);
    localparam IDLE = 2'b00;
    localparam DATA = 2'b01;
    localparam STOP = 2'b10;

    reg [1:0] state;
    reg [5:0] address;
    reg valid;
    reg valid_pipe;

    wire comp;
    assign comp = (address == 6'd63);

    always @(posedge clk) begin
        if (rst) begin
            valid_pipe <= 0;
        end
        else begin
            valid_pipe <= valid;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            address <= 8'd0;
            valid <= 0;
            en <= 0;
        end 
        else begin
            case (state)
                IDLE: begin
                    state <= DATA;
                    en <= 0;
                    valid <= 0;
                end
                DATA: begin
                    if (~comp)begin
                        address <= address + 1;
                        en <= 1;
                        valid <= 1;
                    end
                    else begin
                        state <= STOP;
                        address <= 8'd0;
                        en <= 1;
                        valid <= 1;
                    end
                end
                STOP: begin
                    state <= STOP;
                    address <= 8'd0;
                    en <= 1;
                    valid <= 0;
                end
            endcase
        end
    end
    
    assign valid_in = valid_pipe;

    BRAM_data BRAM (
        .clka(clk),
        .wea(1'b0),
        .addra(address),
        .dina(1024'd0),
        .douta(data)
    );

endmodule