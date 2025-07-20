module SFU #(
    parameter N=8
) (
    input [2:0] INST,
    input clk,
    input rst,
    input ready,
    input [N*16-1:0] in_flat,
    output valid,
    output [15:0] out
);
    reg [N*16-1:0] in_reg;
    reg in_ready;
    reg [15:0] addt_reg;
    reg addt_valid_reg;

    wire addt_valid;
    wire [15:0] addt_out;

    always @(posedge clk) begin
        if (rst) begin
            in_reg <= in_flat;
            in_ready <= ready;
        end
        else begin
            in_reg <= {N{1'b0}};
            in_ready <= 1'b0;
        end
    end

    add_tree #(.N(N)) ADDERT(
        .clk(clk),
        .rst(rst),
        .ready(in_ready),
        .in_flat(in_reg),
        .valid(addt_valid),
        .out(addt_out)
    );

    always @(posedge clk) begin
        if (rst) begin
            addt_reg <= addt_out;
            addt_valid_reg <= addt_valid;
        end
        else begin
            in_reg <= {16{1'b0}};
            in_ready <= 1'b0;
        end
    end

    recip_FP16 your_instance_name (
        .aclk(clk),
        .aresetn(rst),
        .s_axis_a_tvalid(addt_valid_reg),
        .s_axis_a_tready(),
        .s_axis_a_tdata(addt_reg),
        .m_axis_result_tvalid(valid),
        .m_axis_result_tready(1'b1),
        .m_axis_result_tdata(out)
    );
endmodule