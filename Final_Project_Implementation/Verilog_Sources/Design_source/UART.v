//------------------------------------------------------------------------------
// Top: UART <-> BRAM <-> softmax_approx( N=64, Q6.10, latency=40 )
//------------------------------------------------------------------------------
module uart_softmax_top #(
    parameter N          = 64,
    parameter CLK_HZ     = 100_000_000,
    parameter BAUD       = 115200
)(
    input  wire clk,
    input  wire rst_n,          // active-low reset
    input  wire uart_rx_i,
    output wire uart_tx_o,

    output wire busy_o          // 1이면 작업 중
);
    // ---------------- UART ----------------
    wire [7:0] rx_data;
    wire       rx_valid;
    uart_rx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) U_RX (
        .clk(clk), .rst_n(rst_n), .rx_i(uart_rx_i),
        .data_o(rx_data), .valid_o(rx_valid)
    );

    wire [7:0] tx_data;
    wire       tx_valid, tx_ready;
    uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) U_TX (
        .clk(clk), .rst_n(rst_n), .tx_o(uart_tx_o),
        .data_i(tx_data), .valid_i(tx_valid), .ready_o(tx_ready)
    );

    // --------------- BRAM (64 x 16b) ---------------
    reg  [15:0] in_mem  [0:N-1];
    reg  [15:0] out_mem [0:N-1];

    // --------------- 수신 바이트 페어링 ---------------
    localparam integer BYTES = N*2; // 128
    reg  [7:0]   byte_lo;
    reg  [7:0]   byte_hi;
    reg  [7:0]   rx_cnt;
    reg          have_lo;

    // --------------- 송신 FSM ---------------
    reg  [7:0] tx_cnt;
    reg        tx_fire;
    reg  [7:0] tx_data_r;
    assign tx_data  = tx_data_r;
    assign tx_valid = tx_fire;

    // --------------- Softmax Approx 모듈 연결 ---------------
    wire                 sm_valid_out;
    reg                  sm_valid_in;
    wire [N*16-1:0]      prob_flat;
    wire [N*16-1:0]      in_x_flat;

    genvar gi;
    generate
        for (gi=0; gi<N; gi=gi+1) begin : GEN_IN_FLAT
            assign in_x_flat[gi*16 +: 16] = in_mem[gi];
        end
    endgenerate

    integer ii;

    softmax #(
        .N(N)
    ) U_SOFTMAX (
        .clk(clk),
        .en(1'b1),
        .rst(~rst_n),
        .valid_in(sm_valid_in),
        .in_x_flat(in_x_flat),
        .valid_out(sm_valid_out),
        .prob_flat(prob_flat)
    );

    // --------------- 컨트롤 FSM ---------------
    localparam S_IDLE=3'd0, S_RX=3'd1, S_COMPUTE=3'd2,
               S_WAIT=3'd3, S_LATCH=3'd4, S_TX=3'd5;
    reg [2:0] state, nstate;

    assign busy_o = (state != S_IDLE);

    // ---------------- 단일 always 블록 ----------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= S_IDLE;
            rx_cnt      <= 8'd0;
            have_lo     <= 1'b0;
            sm_valid_in <= 1'b0;
            tx_cnt      <= 8'd0;
            tx_fire     <= 1'b0;
        end else begin
            state       <= nstate;
            sm_valid_in <= 1'b0;   // 기본은 0, 특정 조건에서 1클럭 펄스

            // 상태별 제어
            case (state)
                S_IDLE: begin
                    if (nstate==S_RX) begin
                        rx_cnt  <= 8'd0;
                        have_lo <= 1'b0;
                    end
                end

                S_RX: begin
                    if (rx_valid) begin
                        if (!have_lo) begin
                            byte_lo <= rx_data;
                            have_lo <= 1'b1;
                        end else begin
                            byte_hi <= rx_data;
                            in_mem[rx_cnt[7:1]] <= {rx_data, byte_lo};
                            have_lo <= 1'b0;
                            rx_cnt  <= rx_cnt + 8'd2;
                        end
                    end
                    if (nstate==S_COMPUTE)
                        sm_valid_in <= 1'b1;  // softmax 시작 펄스
                end

                S_LATCH: begin
                    for (ii=0; ii<N; ii=ii+1)
                        out_mem[ii] <= prob_flat[ii*16 +: 16];
                    if (nstate==S_TX)
                        tx_cnt <= 8'd0;
                end

                S_TX: begin
                    tx_fire <= 1'b0;
                    if (tx_ready) begin
                        if (!tx_cnt[0])
                            tx_data_r <= out_mem[tx_cnt[7:1]][7:0];  // LO
                        else
                            tx_data_r <= out_mem[tx_cnt[7:1]][15:8]; // HI
                        tx_fire <= 1'b1;
                        tx_cnt  <= tx_cnt + 8'd1;
                    end
                end

                default: ;
            endcase
        end
    end

    // ---------------- 상태 전이 ----------------
    always @* begin
        nstate = state;
        case (state)
            S_IDLE:    nstate = S_RX;
            S_RX:      nstate = (rx_cnt == BYTES) ? S_COMPUTE : S_RX;
            S_COMPUTE: nstate = S_WAIT;
            S_WAIT:    nstate = sm_valid_out ? S_LATCH : S_WAIT;
            S_LATCH:   nstate = S_TX;
            S_TX:      nstate = (tx_cnt == BYTES) ? S_IDLE : S_TX;
            default:   nstate = S_IDLE;
        endcase
    end
endmodule

//------------------------------------------------------------------------------
// Minimal UART RX (8N1)
//------------------------------------------------------------------------------
module uart_rx #(parameter CLK_HZ=100_000_000, parameter BAUD=115200)(
    input  wire clk, input wire rst_n, input wire rx_i,
    output reg  [7:0] data_o, output reg valid_o
);
    localparam integer DIV = CLK_HZ/BAUD;
    localparam integer MID = DIV/2;
    reg [15:0] divcnt; reg [3:0] bitcnt; reg [9:0] sh; reg busy;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin divcnt<=0; bitcnt<=0; busy<=0; valid_o<=0; end
        else begin
            valid_o <= 1'b0;
            if (!busy) begin
                if (!rx_i) begin busy<=1'b1; divcnt<=MID; bitcnt<=4'd0; end
            end else begin
                if (divcnt==0) begin
                    divcnt <= DIV-1;
                    bitcnt <= bitcnt + 1;
                    case (bitcnt)
                        4'd0: ;
                        4'd1,4'd2,4'd3,4'd4,
                        4'd5,4'd6,4'd7,4'd8:
                            sh[bitcnt-1] <= rx_i;
                        4'd9: begin
                            data_o  <= sh[7:0];
                            valid_o <= 1'b1;
                            busy    <= 1'b0;
                        end
                    endcase
                end else divcnt <= divcnt - 1;
            end
        end
    end
endmodule

//------------------------------------------------------------------------------
// Minimal UART TX (8N1)
//------------------------------------------------------------------------------
module uart_tx #(parameter CLK_HZ=100_000_000, parameter BAUD=115200)(
    input  wire clk, input wire rst_n, output wire tx_o,
    input  wire [7:0] data_i, input wire valid_i, output wire ready_o
);
    localparam integer DIV = CLK_HZ/BAUD;
    reg [15:0] divcnt; reg [3:0] bitcnt; reg [9:0] sh; reg busy;

    assign tx_o    = busy ? sh[0] : 1'b1;
    assign ready_o = ~busy;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin busy<=0; divcnt<=0; bitcnt<=0; sh<=10'h3FF; end
        else begin
            if (!busy) begin
                if (valid_i) begin
                    sh    <= {1'b1, data_i, 1'b0}; // stop, data, start
                    busy  <= 1'b1;
                    bitcnt<=4'd0;
                    divcnt<=DIV-1;
                end
            end else begin
                if (divcnt==0) begin
                    divcnt <= DIV-1;
                    sh     <= {1'b1, sh[9:1]};
                    bitcnt <= bitcnt + 1;
                    if (bitcnt==4'd9) busy<=1'b0;
                end else divcnt <= divcnt - 1;
            end
        end
    end
endmodule
