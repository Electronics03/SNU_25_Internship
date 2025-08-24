
module softmax_fsm(
    input wire clk,
    input wire rst_n,
    input wire en,
    input wire [63:0] x_in,
    input wire [7:0] case_num,
    output reg [11:0] addrb, //read
    output reg [63:0] x_out,
    output reg [11:0] addra, //write
    output reg wea,
    output reg pulse_out_softmax
);

    parameter WAIT_READY=2'd0,
              SEND_INPUT=2'd1,
              WAIT_VALID=2'd0,
              RECEIVE_OUTPUT=2'd1;
              
    wire softmax_ready;
    wire softmax_valid;
    wire [63:0] softmax;
    reg x_in_valid;
    reg next_ready;
    
    softmax u_softmax(
        .clk(clk),
        .rst_n(rst_n),
        .x_in(x_in), //64비트 인풋, bram이랑 연결
        .x_in_valid(x_in_valid),
        .next_ready(next_ready),
        .softmax_ready(softmax_ready),
        .softmax_valid(softmax_valid), 
        .softmax(softmax)
    );
    
    reg input_state;
    reg [3:0] case_in_idx;
    reg [4:0] x_in_idx;
    
    reg output_state;
    reg [3:0] case_out_idx;
    reg [4:0] x_out_idx;
    
     
    
    // Input FSM
    always @(posedge clk) begin
        if (!rst_n) begin
            input_state <= WAIT_READY;
            x_in_valid <= 0;
            x_in_idx <= 0;
            case_in_idx <= 0;
            addrb <= 0;
        end 
        else if(en) begin
            case (input_state)
                WAIT_READY: begin
                    if (case_in_idx < case_num) begin
                        if (softmax_ready) begin
                            x_in_valid <= 1;
                            x_in_idx <= x_in_idx + 1;
                            addrb <= addrb + 1;
                            input_state <= SEND_INPUT;
                        end
                    end
                end

                SEND_INPUT: begin
                    if (x_in_idx < 16) begin
                        x_in_idx <= x_in_idx + 1;
                        addrb <= addrb + 1;
                    end 
                    else if (x_in_idx == 16) begin
                        x_in_idx <= 0;
                        x_in_valid <= 0;
                        case_in_idx <= case_in_idx+1;
                        input_state <= WAIT_READY;
                    end
                end
            endcase
        end
    end
    
    // Output FSM
    always @(posedge clk) begin
        if (!rst_n) begin
            output_state <= WAIT_VALID;
            next_ready <= 1; //always 1
            x_out_idx <= 0;
            case_out_idx <= 0;
            addra <= 1024; //저장용 주소 예시
            wea <= 0;
        end 
        else if(en) begin
            case (output_state)
                WAIT_VALID: begin
                    if (case_out_idx < case_num) begin
                        if (softmax_valid) begin
                            x_out <= softmax;
                            wea <= 1;
                            x_out_idx <= x_out_idx + 1;
                            output_state <= RECEIVE_OUTPUT;
                        end
                    end
                    else pulse_out_softmax <= 0;
                end

                RECEIVE_OUTPUT: begin
                    if (x_out_idx < 16) begin
                        x_out <= softmax;
                        x_out_idx <= x_out_idx + 1;
                        addra <= addra + 1;
                    end 
                    else if (x_out_idx == 16) begin
                        x_out_idx <= 0;
                        addra <= addra + 1;
                        wea <= 0;
                        case_out_idx <= case_out_idx+1;
                        output_state <= WAIT_VALID;
                        
                        if(case_out_idx==case_num-1) pulse_out_softmax <= 1;
                    end
                end
            endcase
        end
    end
endmodule
