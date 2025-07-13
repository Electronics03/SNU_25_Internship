module exp_module_tb;
    parameter N = 4;

    reg [N*16-1:0] vect_in_flat;
    reg clk;
    reg rst;
    reg [N-1:0] in_tvalid;
    wire [N-1:0] in_tready;
    wire [N-1:0] out_tvalid;
    wire [N*16-1:0] vect_out_flat;

    initial clk = 0;
    always #5 clk = ~clk;

    exp_module #(.N(N)) UUT (
        .exp_in_flat(vect_in_flat),
        .clk(clk),
        .rst(rst),
        .in_tvalid(in_tvalid),
        .in_tready(in_tready),
        .out_tvalid(out_tvalid),
        .exp_out_flat(vect_out_flat)
    );

    integer i;
    reg [15:0] vect_in [0:N-1];
    reg [15:0] vect_out [0:N-1];

    initial begin
        rst = 0;
        in_tvalid = 0;
        vect_in_flat = 0;

        #2 rst = 0;
        #10 rst = 1;
        #20;

        vect_in[0] = 16'hBC00;
        vect_in[1] = 16'h3EFA;
        vect_in[2] = 16'h4051;
        vect_in[3] = 16'hC034;

        vect_in_flat = 0;
        for (i = 0; i < N; i = i + 1) begin
            vect_in_flat = vect_in_flat | (vect_in[i] << (i*16));
        end

        in_tvalid = {N{1'b1}};
        #10;
        in_tvalid = {N{1'b0}};

        #500;
        $finish;
    end

    always @(posedge clk) begin
        for (i = 0; i < N; i = i + 1) begin
            if (out_tvalid[i]) begin
                vect_out[i] = vect_out_flat[i*16 +:16];
                $display("Time=%0t ns, OUT[%0d] = %0d (hex %h)", $time, i, vect_out[i], vect_out[i]);
            end
        end
    end

endmodule