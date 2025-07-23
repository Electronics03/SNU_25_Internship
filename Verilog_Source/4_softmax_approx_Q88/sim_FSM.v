module sim_FSM #(parameter N = 8)(
    input clk,
    input rst,

    output reg en,
    output reg valid_in,
    output reg [N*16-1:0] in_x_flat
);
    reg [N*16-1:0] mem [0:2];

    initial begin
        mem[0] = { 
            16'hFE44, 16'hFE8E, 16'h0016, 16'hFD9D, 16'hFE51, 16'h0261, 16'hFE6A, 16'hFFF4, 
            16'hFF5D, 16'h02F7, 16'hFFCF, 16'h0107, 16'hFE9B, 16'h00B6, 16'hFE40, 16'h022A, 
            16'h005C, 16'h0111, 16'h0052, 16'h01EA, 16'h0015, 16'h02EC, 16'h0063, 16'h01E5, 
            16'hFF69, 16'hFD4E, 16'hFF60, 16'h020F, 16'hFFB9, 16'h00C1, 16'hFEB1, 16'hFDEF, 
            16'h0214, 16'hFE8B, 16'h0209, 16'h01D0, 16'h0149, 16'hFF90, 16'h012A, 16'h02A7, 
            16'hFFC3, 16'hFFAD, 16'hFDEA, 16'h0035, 16'h0207, 16'h00B8, 16'hFFE0, 16'hFF3B, 
            16'h00A2, 16'hFD32, 16'h02A7, 16'h008E, 16'hFEE7, 16'h0226, 16'hFED0, 16'h020E, 
            16'hFE29, 16'h014F, 16'h0017, 16'h0195, 16'hFF3C, 16'hFD8F, 16'h01C4, 16'h00CD
        };
        mem[1] = {
            16'hFF27, 16'hFDCF, 16'hFE96, 16'hFD35, 16'hFF70, 16'hFD09, 16'h01A9, 16'hFD52, 
            16'h02E8, 16'h00D1, 16'h0188, 16'h0085, 16'hFD45, 16'h020A, 16'hFF74, 16'hFE76, 
            16'h013A, 16'hFFCA, 16'h0152, 16'hFEB8, 16'hFD99, 16'h0237, 16'h023C, 16'hFDBE, 
            16'h01CB, 16'h00B2, 16'h0089, 16'h02A1, 16'hFD91, 16'h02C9, 16'h00F1, 16'h002A, 
            16'hFEC0, 16'h0057, 16'h02C4, 16'hFE3E, 16'h02E3, 16'h02CB, 16'h023E, 16'hFD17, 
            16'hFF6C, 16'hFE6E, 16'hFFEB, 16'h00EF, 16'h0234, 16'h00DF, 16'h0131, 16'h02EC, 
            16'hFEAD, 16'h0035, 16'h02B6, 16'h010C, 16'hFED3, 16'h02B2, 16'hFF94, 16'hFF11, 
            16'h003E, 16'hFD4C, 16'h006C, 16'h00EC, 16'h017A, 16'h0041, 16'hFED7, 16'hFD70
        };
        mem[2] = {
            16'hFDF2, 16'h0071, 16'h01F9, 16'hFD1F, 16'h0093, 16'h00BD, 16'hFE62, 16'h0012,
            16'hFFDC, 16'h0100, 16'h02C6, 16'h020D, 16'hFEB2, 16'h009F, 16'h0014, 16'hFFAE,
            16'h0175, 16'hFD96, 16'hFE3D, 16'h024F, 16'h00BC, 16'hFE2E, 16'hFEF9, 16'h01F9,
            16'h00C7, 16'hFD32, 16'h006C, 16'h009E, 16'h0141, 16'h027F, 16'hFF51, 16'hFD18,
            16'hFF89, 16'hFD79, 16'h01F4, 16'hFDDC, 16'h029F, 16'h02D2, 16'h0232, 16'h0107,
            16'hFEC0, 16'h0190, 16'h02B0, 16'hFF48, 16'h016C, 16'hFE85, 16'hFE87, 16'hFD6E,
            16'h02A1, 16'hFDF8, 16'hFD06, 16'h01FE, 16'hFF7A, 16'h0211, 16'h0060, 16'hFE5E,
            16'hFE15, 16'h01EB, 16'hFECE, 16'h010C, 16'h0270, 16'h0190, 16'hFF39, 16'h01B0
        };
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