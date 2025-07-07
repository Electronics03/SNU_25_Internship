module log2_approx (
    input  wire [15:0] in_x,
    output wire [15:0] log2_x
);
    reg [3:0] count;
    wire [15:0] frac_part;
    reg [3:0] int_part;

    always @(*) begin
        casex (in_x)
            16'b1xxx_xxxx_xxxx_xxxx: begin count = 4'd0; int_part = 4'b0011; end
            16'b01xx_xxxx_xxxx_xxxx: begin count = 4'd1; int_part = 4'b0010; end
            16'b001x_xxxx_xxxx_xxxx: begin count = 4'd2; int_part = 4'b0001; end
            16'b0001_xxxx_xxxx_xxxx: begin count = 4'd3; int_part = 4'b0000; end
            16'b0000_1xxx_xxxx_xxxx: begin count = 4'd4; int_part = 4'b1111; end
            16'b0000_01xx_xxxx_xxxx: begin count = 4'd5; int_part = 4'b1110; end
            16'b0000_001x_xxxx_xxxx: begin count = 4'd6; int_part = 4'b1101; end
            16'b0000_0001_xxxx_xxxx: begin count = 4'd7; int_part = 4'b1100; end
            16'b0000_0000_1xxx_xxxx: begin count = 4'd8; int_part = 4'b1011; end
            16'b0000_0000_01xx_xxxx: begin count = 4'd9; int_part = 4'b1010; end
            16'b0000_0000_001x_xxxx: begin count = 4'd10; int_part = 4'b1001; end
            16'b0000_0000_0001_xxxx: begin count = 4'd11; int_part = 4'b1000; end
            16'b0000_0000_0000_1xxx: begin count = 4'd12; int_part = 4'b0111; end
            16'b0000_0000_0000_01xx: begin count = 4'd13; int_part = 4'b0110; end
            16'b0000_0000_0000_001x: begin count = 4'd14; int_part = 4'b0101; end
            16'b0000_0000_0000_0001: begin count = 4'd15; int_part = 4'b0100; end
        endcase
    end
    assign frac_part = in_x << count;
    assign log2_x = {int_part, frac_part[14:3]};
endmodule


module pow2_approx(
    input wire signed [15:0] in_x,
    output wire signed [15:0] pow2_x
);

    wire signed [3:0] int_part;
    wire [11:0] frac_part;
    wire signed [15:0] one_plus_frac;
    wire signed [31:0] mult_result;

    assign int_part = in_x[15:12];
    assign frac_part = in_x[11:0];
    assign one_plus_frac = {4'b0001, frac_part};

    assign mult_result = (int_part >= 0) ? (one_plus_frac <<< int_part) : (one_plus_frac >>> (-int_part));
    
    assign pow2_x = mult_result[15:0];
endmodule