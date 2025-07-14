module VFU #(
    parameter N = 64
)(
    input [N*16-1:0] vect_A_in,
    input [N*16-1:0] vect_B_in,
    input [1:0] INST,
    input clk,
    input rst,
    output reg [N*16-1:0] vect_out_flat,
    output reg out_tvalid
);    
    reg [3:0] valid;
    reg [N*16-1:0] vect_A;
    reg [N*16-1:0] vect_B;

    wire [N*16-1:0] sub_result;
    wire [N*16-1:0] exp_result;
    wire [N*16-1:0] add_result;
    wire [N*16-1:0] mult_result;
    wire [N*16-1:0] bypass_result;

    always @(posedge clk) begin
        if(rst) begin
            vect_A <= vect_A_in;
            vect_B <= vect_B_in;
        end
        else begin
            vect_A <= {N{16'd0}};
            vect_B <= {N{16'd0}};
        end
    end

    always @(*) begin
        case (INST)
            2'b00: valid = 4'b1000;
            2'b01: valid = 4'b0100;
            2'b10: valid = 4'b0010;
            2'b11: valid = 4'b0001;
        endcase
    end



    wire mult_valid, add_valid, sub_valid, exp_valid;
    wire sub_exp_valid;

    assign bypass_result = vect_A;

    add_module #(.N(N)) ADDM (
        .add_in_A_flat(vect_A),
        .add_in_B_flat(vect_B),
        .clk(clk),
        .rst(rst),
        .in_tvalid({N{valid[2]}}),
        .in_tready(),
        .out_tvalid(add_valid),
        .add_out_flat(add_result)
    );

    mult_module #(.N(N)) MULTM (
        .mult_in_A_flat(vect_A),
        .mult_in_B_flat(vect_B),
        .clk(clk),
        .rst(rst),
        .in_tvalid({N{valid[3]}}),
        .in_tready(),
        .out_tvalid(mult_valid),
        .mult_out_flat(mult_result)
    );

    sub_module #(.N(N)) SUBM (
        .sub_in_A_flat(vect_A),
        .sub_in_B_flat(vect_B),
        .clk(clk),
        .rst(rst),
        .in_tvalid({N{valid[1]}}),
        .in_tready(),
        .out_tvalid(sub_valid),
        .sub_out_flat(sub_result)
    );

    exp_module #(.N(N)) EXPM (
        .exp_in_flat(sub_result),
        .clk(clk),
        .rst(rst),
        .in_tvalid({N{sub_valid}}),
        .in_tready(),
        .out_tvalid(exp_valid),
        .exp_out_flat(exp_result)
    );

    assign sub_exp_valid = exp_valid;
    always @(*) begin
        case (INST)
            2'b00: vect_out_flat = mult_result;
            2'b01: vect_out_flat = add_result;
            2'b10: vect_out_flat = exp_result;
            2'b11: vect_out_flat = bypass_result;
        endcase
    end

    always @(*) begin
    case (INST)
        2'b00: out_tvalid = mult_valid;
        2'b01: out_tvalid = add_valid;
        2'b10: out_tvalid = exp_valid;
        2'b11: out_tvalid = 1'b1;
        default: out_tvalid = 1'b0;
    endcase
end
endmodule
