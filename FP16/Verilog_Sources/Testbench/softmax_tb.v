`timescale 1ns / 1ps

module softmax_tb();

    reg clk = 0;
    always #5 clk = ~clk; 
    reg rst_n = 0;

    reg [1023:0] x_in;
    reg x_in_valid;
    wire softmax_ready;

    wire softmax_valid;
    wire [1023:0] softmax;

    softmax uut(
        .clk(clk),
        .rst_n(rst_n),

        .x_in(x_in),
        .x_in_valid(x_in_valid), 
        .softmax_ready(softmax_ready),

        .next_ready(1),
        .softmax_valid(softmax_valid), 
        .softmax(softmax)
    );

    localparam [1023:0] my_x_1 = { 
        64'hB591C40437A84099,
        64'hB6A7B86CB9F63CC1,
        64'h3F1347594378BEF3,
        64'hC30C43EBBAE546CA,

        64'hC5C9361B430EB83D,
        64'h36CFB537399840C0,
        64'h3C9DC3ED427DC50B,
        64'hB45B378846A146FC,

        64'h467246013DA2BE70,
        64'hC033C783C128C190,
        64'h3E03BE36C4CD3AF7,
        64'h3D1C46EDB70F437C,

        64'hB4553B0635E1C2EF,
        64'h42D2BC97BD873F2A,
        64'hBCB6BD6B393E3E6E,
        64'h3B6A47BFC7A2C73D
    };

    localparam [1023:0] my_x_2 = { 
        64'h4743452F3FCEC37D, 
        64'hC4F43A44C63E3D41, 
        64'h419A474FC5FCB566, 
        64'h4473362BBE80C233,
        
        64'hBC66369646C8C5C7, 
        64'h41893B9F45303FF0, 
        64'h478D3AB5430437D0, 
        64'h39894428348E47F6,
        
        64'hC554C200BF29B6AA, 
        64'hB7F6469FC642C699, 
        64'hBE29468AB5BDB693, 
        64'hB95AB84F347544D2,
        
        64'hB99A4747391BB64E, 
        64'h3746B852B47EC684, 
        64'h3F0C3F0D3B043C02, 
        64'h3D2CC74FBFA33FA7
    };


    initial begin
        $display("Start simulation");
        rst_n = 0; x_in_valid = 0;
        #10 rst_n = 1;

        #30
        x_in_valid = 1;
        x_in = my_x_1;
        #10;
        x_in_valid = 0;

        #1000;
        x_in_valid = 1;
        x_in = my_x_2;
        #10;
        x_in_valid = 0;

        #2000
        $finish;
    end
endmodule