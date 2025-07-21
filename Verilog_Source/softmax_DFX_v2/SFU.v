module SFU #(
    parameter N = 64
) (
    input clk,
    input rst,

    input [N-1:0] tvalid_in,
    input [N-1:0] tlast_in,
    input [N*16-1:0] tdata_in,

    output tvalid_out,
    input tready_out,
    output [15:0] tdata_out,

    output tvalid_bypass_out,
    output [N*16-1:0] tdata_bypass_out,


    output [15:0] tdata_addt_out_test
);
    reg [N-1:0] reg_tvalid_in;
    reg [N-1:0] reg_tlast_in;
    reg [N*16-1:0] reg_tdata_in;

    always @(posedge clk) begin
        if (rst) begin
            reg_tvalid_in <= {N{1'b0}};
            reg_tlast_in <= {N{1'b0}};
            reg_tdata_in <= {N{16'd0}};
        end
        else begin
            reg_tvalid_in <= tvalid_in;
            reg_tlast_in <= tlast_in;
            reg_tdata_in <= tdata_in;
        end
    end

    fifo_delay #(.DELAY(12*$clog2(N)+4), .N(N)) FIFO (
        .clk(clk),
        .rst(rst),
        .din(reg_tdata_in),
        .valid_in(&(reg_tvalid_in)),
        .dout(tdata_bypass_out),
        .valid_out(tvalid_bypass_out)
    );

    wire [N-1:0] tvalid_addt_in;
    wire [N-1:0] tlast_addt_in;
    wire [N*16-1:0] tdata_addt_in;
    assign tvalid_addt_in = reg_tvalid_in;
    assign tlast_addt_in = reg_tlast_in;
    assign tdata_addt_in = reg_tdata_in;

    wire tvalid_addt_out;
    wire tready_addt_out;
    wire [15:0] tdata_addt_out;

    assign tdata_addt_out_test = tdata_addt_out;

    adder_tree #(.N(N)) ADDT (
        .clk(clk),

        .tvalid_in(tvalid_addt_in),
        .tready_in(),
        .tlast_in(tlast_addt_in),
        .tdata_in(tdata_addt_in),

        .tvalid_out(tvalid_addt_out),
        .tready_out(tready_addt_out),
        .tlast_out(),
        .tdata_out(tdata_addt_out)
    );

    wire tvalid_recip_in;
    wire tready_recip_in;
    wire [15:0] tdata_recip_in;
    assign tvalid_recip_in = tvalid_addt_out;
    assign tready_addt_out = tready_recip_in;
    assign tdata_recip_in = tdata_addt_out;

    wire tvalid_recip_out;
    wire tready_recip_out;
    wire [15:0] tdata_recip_out;

    recip_FP16 RECIP (
        .aclk(clk),

        .s_axis_a_tvalid(tvalid_recip_in),
        .s_axis_a_tready(tready_recip_in),
        .s_axis_a_tdata(tdata_recip_in),

        .m_axis_result_tvalid(tvalid_recip_out),
        .m_axis_result_tready(tready_recip_out),
        .m_axis_result_tdata(tdata_recip_out)
    );

    assign tvalid_out = tvalid_recip_out;
    assign tready_recip_out = tready_out;
    assign tdata_out = tdata_recip_out;
endmodule