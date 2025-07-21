module softmax_top (
    input wire clk,
    input wire rst,
    input wire en,
    input wire valid_in,
    input wire [63:0] in_data,
    input wire [15:0] max_x,

    output reg [15:0] out_data,
    output reg valid_out
);
    parameter N = 64;

    reg [15:0] in_buffer [0:N-1];
    reg [15:0] out_buffer [0:N-1];
    reg [5:0] write_idx = 0;
    reg [5:0] read_idx = 0;

    reg softmax_start = 0;
    wire softmax_done;

    wire [N*16-1:0] in_x_flat;
    wire [N*16-1:0] prob_flat;

    softmax #(.N(N)) softmax_inst (
        .clk(clk),
        .rst(rst),
        .en(softmax_start),
        .valid_in(softmax_start),
        .in_x_flat(in_x_flat),
        .max_x(max_x),
        .valid_out(softmax_done),
        .prob_flat(prob_flat)
    );

    always @(posedge clk) begin
        if (rst) begin
            write_idx <= 0;
            softmax_start <= 0;
        end else if (valid_in && write_idx < N) begin
            in_buffer[write_idx + 0] <= in_data[15:0];
            in_buffer[write_idx + 1] <= in_data[31:16];
            in_buffer[write_idx + 2] <= in_data[47:32];
            in_buffer[write_idx + 3] <= in_data[63:48];
            write_idx <= write_idx + 4;

            if (write_idx + 4 >= N)
                softmax_start <= 1;
        end else begin
            softmax_start <= 0;
        end
    end

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin
            assign in_x_flat[i*16 +: 16] = in_buffer[i];
        end
    endgenerate

    integer j;
    always @(posedge clk) begin
        if (rst) begin
            read_idx <= 0;
        end else if (softmax_done) begin
            for (j = 0; j < N; j = j + 1) begin
                out_buffer[j] <= prob_flat[j*16 +: 16];
            end
            read_idx <= 0;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            valid_out <= 0;
            out_data <= 16'd0;
            read_idx <= 0;
        end else if (softmax_done || valid_out) begin
            if (read_idx < N) begin
                out_data <= out_buffer[read_idx];
                valid_out <= 1;
                read_idx <= read_idx + 1;
            end else begin
                valid_out <= 0;
            end
        end
    end
endmodule
