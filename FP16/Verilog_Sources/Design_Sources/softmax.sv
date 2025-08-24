// Input 4 16bit FP data for 16 cycles
// Calculate softmax
// Output 8 16bit FP data for 8 cycles

module softmax(
    input wire clk,
    input wire rst_n,
    input wire [63:0] x_in,
    input wire x_in_valid, 
    input wire next_ready,
    output wire softmax_ready,
    output wire softmax_valid, 
    output wire [63:0] softmax
    );
    
    wire modified_x_1024_valid;
    wire max_valid;
    wire max_ready_all;
    wire [15:0] max;
    wire [63:0] subexp_a_ready;
    wire [63:0] subexp_b_ready;
    wire subexp_a_ready_all;
    wire subexp_b_ready_all;
    wire modified_max_valid;
    wire [63:0] subexp_valid; //for & operation
    wire [15:0] subexp [0:63];
    wire [64*16-1:0] subexp_flatten;
    wire subexp_valids;
    wire modified_sum_delay_ready;
    wire modified_subexp_valid;
    wire sum_ready_all;
    wire sum_valid;
    wire [15:0] sum;
    wire recip_ready;
    wire recip_valid;
    wire [15:0] recip;
    wire [63:0] mult_a_ready;
    wire [63:0] mult_b_ready;
    wire mult_a_ready_all;
    wire mult_b_ready_all;
    wire modified_recip_valid;
    wire [63:0] mult_valid; //for & operation
    wire [15:0] mult [0:63];
    wire [64*16-1:0] mult_flatten;
    wire mult_valids;
    
    wire x_1024_ready;
    wire x_1024_valid;
    wire [64*16-1:0] x_1024;
    wire max_delay_ready_all;
        
    wire x_64_ready;
    wire x_64_valid;
    wire [63:0] x_64;
    wire modified_x_64_ready;
    
    wire [3:0] x_delayed_ready;
    wire [3:0] x_delayed_valid;
    wire [15:0] x_delayed [0:3][0:63];
    wire modified_x_delayed_valid0;
    wire modified_x_delayed_valid3;
    wire [15:0] x_1024_arr [0:63];
    
    // If this module is ready to receive new input, 'softmax_ready' is high 
    assign softmax_ready=x_1024_ready;
    
    //0. input data buffer (64 * 16 times = 1024)
    shiftreg_64_1024 u_sr_64_1024(
        .clk(clk),
        .rst_n(rst_n),
        .x_64(x_in),
        .x_64_valid(x_in_valid), 
        .next_ready(max_delay_ready_all),
        .x_1024_ready(x_1024_ready),
        .x_1024_valid(x_1024_valid), 
        .x_1024(x_1024) // output 1024 bit (64 16bit FP) 
    );

    //// for 1 : n data transfer ////
    assign max_delay_ready_all=max_ready_all & x_delayed_ready[0];
    assign modified_x_1024_valid=x_1024_valid & max_delay_ready_all; 
    
    // from 0 state to 2 stage Pipelined register
    genvar i;
    generate
        for(i=0; i<64; i=i+1) begin
            assign x_1024_arr[i]=x_1024[i*16 +: 16];
        end
    endgenerate
    pipelined_reg #(.WIDTH(16), .DEPTH(64), .DELAY(10)) u_pr0(
        .clk(clk),
        .rst_n(rst_n),
        .x_in(x_1024_arr),
        .x_in_valid(modified_x_1024_valid), 
        .next_ready(subexp_a_ready_all),
        .x_delayed_ready(x_delayed_ready[0]),
        .x_delayed_valid(x_delayed_valid[0]), 
        .x_delayed(x_delayed[0])
    );
    
    //1. Max among 64 16bit FPs
    FP16_max64 u_max64(
        .clk(clk),
        .rst_n(rst_n),
        .x(x_1024),
        .x_valid(modified_x_1024_valid),
        .max_ready_all(max_ready_all),
        .next_ready(subexp_b_ready_all), 
        .max_valid(max_valid), 
        .max(max) // output 16bit FP
    );
    
    //// for 1 : n data transfer ////
    assign subexp_a_ready_all=&subexp_a_ready;
    assign subexp_b_ready_all=&subexp_b_ready;
    assign modified_x_delayed_valid0=x_delayed_valid[0] & subexp_a_ready_all;
    assign modified_max_valid=max_valid & subexp_b_ready_all; 
       
    //2. Subtract Max from 16bit FP each, and apply exponential function
    generate
        for(i=0; i<64; i=i+1) begin: u_subexp
            FP16_subexp u_subexp(
                .clk(clk),
                .rst_n(rst_n),
                .a(x_delayed[0][i]),
                .b(max),
                .a_valid(modified_x_delayed_valid0),
                .b_valid(modified_max_valid), 
                .a_ready(subexp_a_ready[i]),
                .b_ready(subexp_b_ready[i]),
                .next_ready(modified_sum_delay_ready),
                .subexp_valid(subexp_valid[i]), 
                .subexp(subexp[i]) // output 16bit FP each
            );
        end
    endgenerate
    generate
        for (i=0; i<64; i=i+1) begin
            assign subexp_flatten[i*16 +: 16] = subexp[i]; //Flat 64 16bit FP to 1024 bit
        end
    endgenerate

    //// for n : n data transfer ////
    assign subexp_valids=&subexp_valid;
    assign sum_delay_ready=sum_ready_all & x_delayed_ready[1];
    assign modified_sum_delay_ready=sum_delay_ready & subexp_valids;
    assign modified_subexp_valid=subexp_valids & sum_delay_ready;

    // from 2 stage to 5 stage Pipelined register
    pipelined_reg #(.WIDTH(16), .DEPTH(64), .DELAY(15)) u_pr1(
        .clk(clk),
        .rst_n(rst_n),
        .x_in(subexp),
        .x_in_valid(modified_subexp_valid), 
        .next_ready(x_delayed_ready[2]),
        .x_delayed_ready(x_delayed_ready[1]),
        .x_delayed_valid(x_delayed_valid[1]), 
        .x_delayed(x_delayed[1])
    );
    pipelined_reg #(.WIDTH(16), .DEPTH(64), .DELAY(15)) u_pr2(
        .clk(clk),
        .rst_n(rst_n),
        .x_in(x_delayed[1]),
        .x_in_valid(x_delayed_valid[1]), 
        .next_ready(x_delayed_ready[3]),
        .x_delayed_ready(x_delayed_ready[2]),
        .x_delayed_valid(x_delayed_valid[2]), 
        .x_delayed(x_delayed[2])
    );
    pipelined_reg #(.WIDTH(16), .DEPTH(64), .DELAY(15)) u_pr3(
        .clk(clk),
        .rst_n(rst_n),
        .x_in(x_delayed[2]),
        .x_in_valid(x_delayed_valid[2]), 
        .next_ready(mult_a_ready_all),
        .x_delayed_ready(x_delayed_ready[3]),
        .x_delayed_valid(x_delayed_valid[3]), 
        .x_delayed(x_delayed[3])
    );

    //3. Sum 64 sub&exp results (Input must be flatten)
    FP16_add64 u_add64(
        .clk(clk),
        .rst_n(rst_n),
        .x(subexp_flatten),
        .x_valid(modified_subexp_valid), 
        .sum_ready_all(sum_ready_all), 
        .next_ready(recip_ready),
        .sum_valid(sum_valid), 
        .sum(sum) // output 16bit FP
    );

    //4. Reciprocal Sum
    FP16_recip u_recip(
        .aclk(clk),             
        .aresetn(rst_n),                   
        .s_axis_a_tvalid(sum_valid),
        .s_axis_a_tready(recip_ready),
        .s_axis_a_tdata(sum),
        .m_axis_result_tvalid(recip_valid),
        .m_axis_result_tready(mult_b_ready_all),
        .m_axis_result_tdata(recip) // output 16bit FP
    );
    
    //// for 1 : n data transfer ////
    assign mult_a_ready_all=&mult_a_ready;
    assign mult_b_ready_all=&mult_b_ready;
    assign modified_x_delayed_valid3=x_delayed_valid[3] & mult_a_ready_all;
    assign modified_recip_valid=recip_valid & mult_b_ready_all;

    //5. Multiply Recip and sub&exp results each
    generate
        for(i=0; i<64; i=i+1) begin: u_mult
            FP16_mult u_mult(
                .aclk(clk),
                .aresetn(rst_n),
                .s_axis_a_tvalid(modified_x_delayed_valid3),
                .s_axis_a_tready(mult_a_ready[i]),
                .s_axis_a_tdata(x_delayed[3][i]),
                .s_axis_b_tvalid(modified_recip_valid),
                .s_axis_b_tready(mult_b_ready[i]),
                .s_axis_b_tdata(recip),
                .m_axis_result_tvalid(mult_valid[i]),
                .m_axis_result_tready(x_64_ready),
                .m_axis_result_tdata(mult[i]) // output 16bit FP each
            );
        end
    endgenerate
    generate
        for (i=0; i<64; i=i+1) begin
            assign mult_flatten[i*16 +: 16] = mult[i]; //Flat
        end
    endgenerate
    
    //// for n : 1 data transfer ////
    assign mult_valids=&mult_valid;
    assign modified_x_64_ready=x_64_ready & mult_valids;

    //6. output data buffer (1024 = 64 * 16 times)
    shiftreg_1024_64 u_sr_1024_64(
        .clk(clk),
        .rst_n(rst_n),
        .x_1024(mult_flatten),
        .x_1024_valid(mult_valids), 
        .next_ready(next_ready),
        .x_64_ready(x_64_ready),
        .x_64_valid(x_64_valid), 
        .x_64(x_64) // output 64bit (4 16bit FP)
    );
    
    // If this module is valid to send new output, 'softmax_valid' is high 
    assign softmax_valid=x_64_valid;
    assign softmax=x_64;
endmodule 