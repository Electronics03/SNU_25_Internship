// ============================================================
// UART(128B) -> Softmax(N=64) -> UART(128B)
// - 입력: 128B(=64x16b, LSB-first) 수신 후 일괄 Softmax
// - 출력: 128B(=64x16b, LSB-first) 결과 전송
// - 보드: Nexys A7 (rxd=C4, txd=D4), clk=100MHz
// - PC  : 115200 baud, 8N1, No flow control
// ============================================================

// ------------------------------------------------------------
// uart_tx  (질문 제공 버전)
// ------------------------------------------------------------
module uart_tx (
    clk,
    baud_rate_select,
    start,
    Byte_To_Send,
    Tx_Active,
    Tx_Serial,
    Tx_Done,
    rst
);
    input       clk;
    input       rst;
    input [2:0] baud_rate_select;
    input       start;
    input [7:0] Byte_To_Send; 
    output      Tx_Active;
    output reg  Tx_Serial;
    output      Tx_Done;
 
    parameter IDLE         = 3'b000;
    parameter TX_START_BIT = 3'b001;
    parameter TX_DATA_BITS = 3'b010;
    parameter TX_STOP_BIT  = 3'b011;
    parameter RESET        = 3'b100;
    
    reg [10:0]   baud_rate;
    reg [2:0]    State;
    reg [10:0]   clk_count;
    reg [2:0]    bit_index;
    reg [7:0]    Data_Byte;
    reg          Tx_Done;
    reg          Tx_Enable;
     
    always @(*) begin
        case (baud_rate_select)
            3'b101: baud_rate = 11'd391; // 115200
            default: baud_rate = 11'd391;
        endcase
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            State     <= IDLE;
            clk_count <= 11'd0;
            bit_index <= 3'd0;
            Data_Byte <= 8'd0;
            Tx_Done   <= 1'b0;
            Tx_Enable <= 1'b0;
        end else begin
            case (State)
                IDLE: begin
                    Tx_Serial <= 1'b1; // idle high
                    Tx_Done   <= 1'b0;
                    clk_count <= 11'd0;
                    bit_index <= 3'd0;
                    if (start) begin
                        Tx_Enable <= 1'b1;
                        Data_Byte <= Byte_To_Send;
                        State     <= TX_START_BIT;
                    end else begin
                        State <= IDLE;
                    end
                end
                TX_START_BIT: begin
                    Tx_Serial <= 1'b0;
                    if (clk_count < (baud_rate-1)) begin
                        clk_count <= clk_count + 1'b1;
                        State     <= TX_START_BIT;
                    end else begin
                        clk_count <= 11'd0;
                        State     <= TX_DATA_BITS;
                    end
                end
                TX_DATA_BITS: begin
                    Tx_Serial <= Data_Byte[bit_index];
                    if (clk_count < (baud_rate-1)) begin
                        clk_count <= clk_count + 1'b1;
                        State     <= TX_DATA_BITS;
                    end else begin
                        clk_count <= 11'd0;
                        if (bit_index == 3'b111) begin
                            bit_index <= 3'd0;
                            State     <= TX_STOP_BIT;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                            State     <= TX_DATA_BITS;
                        end
                    end
                end
                TX_STOP_BIT: begin
                    Tx_Serial <= 1'b1;
                    if (clk_count < (baud_rate-1)) begin
                        clk_count <= clk_count + 1'b1;
                        State     <= TX_STOP_BIT;
                    end else begin
                        Tx_Done   <= 1'b1;
                        clk_count <= 11'd0;
                        State     <= RESET;
                        Tx_Enable <= 1'b0;
                    end
                end
                RESET: begin
                    Tx_Done <= 1'b0; // one-cycle pulse cleared
                    State   <= IDLE;
                end
                default: State <= IDLE;
            endcase
        end
    end

    assign Tx_Active = Tx_Enable;
endmodule

// ------------------------------------------------------------
// uart_rx  (질문 제공 버전: 반비트 지연 후 중앙 샘플)
// ------------------------------------------------------------
module uart_rx (
    clk, 
    baud_rate_select, 
    Rx_Serial, 
    Rx_Done, 
    Rx_Out, 
    rst
);
    input        clk;
    input        rst;
    input [2:0]  baud_rate_select;
    input        Rx_Serial;
    output       Rx_Done;
    output [7:0] Rx_Out;

    reg [10:0]   baud_rate;  
    reg          Data_Received_R;
    reg          Data_Received;
    reg          Rx_Done; 
    reg [10:0]   clk_count;
    reg [2:0]    bit_index; // 8 bits
    reg [7:0]    Data_Byte;
    reg [2:0]    State;
    
    parameter IDLE         = 3'b000;
    parameter RX_START_BIT = 3'b001;
    parameter RX_DATA_BITS = 3'b010;
    parameter RX_STOP_BIT  = 3'b011;
    parameter RESET        = 3'b100;
    
    always @(*) begin
        case (baud_rate_select)
            3'b101: baud_rate = 11'd391; // 115200
            default: baud_rate = 11'd391;
        endcase
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            State           <= IDLE;
            clk_count       <= 11'd0;
            bit_index       <= 3'd0;
            Data_Received   <= 1'b0;
            Data_Received_R <= 1'b0;
            Rx_Done         <= 1'b0;
            Data_Byte       <= 8'd0;
        end else begin
            Data_Received_R <= Rx_Serial;
            Data_Received   <= Data_Received_R;
            case (State)
                IDLE: begin
                    Rx_Done   <= 1'b0;
                    clk_count <= 11'd0;
                    bit_index <= 3'd0;
                    if (Data_Received == 1'b0) State <= RX_START_BIT;
                    else                        State <= IDLE;
                end
                RX_START_BIT: begin
                    if (clk_count == ((baud_rate - 1'b1) >> 1)) begin
                        if (Data_Received == 1'b0) begin
                            clk_count <= 11'd0;
                            State     <= RX_DATA_BITS;
                        end else begin
                            State <= IDLE;
                        end
                    end else begin
                        clk_count <= clk_count + 1'b1;
                        State     <= RX_START_BIT;
                    end
                end
                RX_DATA_BITS: begin
                    if (clk_count < (baud_rate - 1'b1)) begin
                        clk_count <= clk_count + 1'b1;
                        State     <= RX_DATA_BITS;
                    end else begin
                        clk_count <= 11'd0;
                        Data_Byte[bit_index] <= Data_Received;
                        if (bit_index == 3'b111) begin
                            bit_index <= 3'd0;
                            State     <= RX_STOP_BIT;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                            State     <= RX_DATA_BITS;
                        end
                    end
                end
                RX_STOP_BIT: begin
                    if (clk_count < (baud_rate - 1'b1)) begin
                        clk_count <= clk_count + 1'b1;
                        State     <= RX_STOP_BIT;
                    end else begin
                        Rx_Done   <= 1'b1;
                        clk_count <= 11'd0;
                        State     <= RESET;
                    end
                end
                RESET: begin
                    State   <= IDLE;
                    Rx_Done <= 1'b0;
                end
                default: State <= IDLE;
            endcase
        end
    end

    assign Rx_Out = Data_Byte;
endmodule

// ------------------------------------------------------------
// 128바이트 블록 수신 버퍼 (조합 읽기 포트)
// ------------------------------------------------------------
module uart_block_rx_128 (
    input  wire        clk,         // 100MHz
    input  wire        rst,
    input  wire        rxd,         // PC -> FPGA
    input  wire [2:0]  baud_sel,    // 3'b101 (115200)
    input  wire        consume,     // 1클럭 펄스: 블록 소비/초기화

    output reg         block_ready, // 1: 버퍼 가득 참(128B)
    output reg  [7:0]  byte_count,  // 수신된 바이트 수(0..128)
    output reg         overrun,     // 가득 찬 상태에서 추가 수신 발생

    input  wire [6:0]  rd_addr,     // 0..127
    output wire [7:0]  rd_data
);
    reg [7:0] mem [0:127];

    wire       rx_done;
    wire [7:0] rx_byte;

    uart_rx u_rx (
        .clk              (clk),
        .baud_rate_select (baud_sel),
        .Rx_Serial        (rxd),
        .Rx_Done          (rx_done),
        .Rx_Out           (rx_byte),
        .rst              (rst)
    );

    assign rd_data = mem[rd_addr];

    reg [6:0] wr_ptr;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr      <= 7'd0;
            block_ready <= 1'b0;
            byte_count  <= 8'd0;
            overrun     <= 1'b0;
        end else begin
            if (consume) begin
                wr_ptr      <= 7'd0;
                block_ready <= 1'b0;
                byte_count  <= 8'd0;
                overrun     <= 1'b0;
            end
            if (rx_done) begin
                if (!block_ready) begin
                    mem[wr_ptr] <= rx_byte;
                    if (wr_ptr == 7'd127) begin
                        block_ready <= 1'b1;
                        byte_count  <= 8'd128;
                    end else begin
                        wr_ptr     <= wr_ptr + 7'd1;
                        byte_count <= byte_count + 8'd1;
                    end
                end else begin
                    overrun <= 1'b1;
                end
            end
        end
    end
endmodule

// ------------------------------------------------------------
// 상위: 128B -> Softmax(N=64) -> 128B 전송 (tx_done 기반 페이싱)
// ------------------------------------------------------------
module uart_softmax64_top (
    input  wire clk,     // 100 MHz
    input  wire rst_n,
    input  wire rxd,     // C4 (FTDI TXD -> FPGA RX)
    output wire txd      // D4 (FPGA TX  -> FTDI RXD)
);
    localparam [2:0] BAUD_SEL = 3'b101; // 115200bps (868)
    
    wire rst;
    assign rst = ~rst_n;

    // 128B 수신 버퍼
    wire        block_ready;
    wire [7:0]  byte_count;
    wire        overrun;
    reg         consume;
    reg  [6:0]  rd_addr;
    wire [7:0]  rd_data;

    uart_block_rx_128 u_buf (
        .clk        (clk),
        .rst        (rst),
        .rxd        (rxd),
        .baud_sel   (BAUD_SEL),
        .consume    (consume),
        .block_ready(block_ready),
        .byte_count (byte_count),
        .overrun    (overrun),
        .rd_addr    (rd_addr),
        .rd_data    (rd_data)
    );

    // Softmax N=64
    localparam integer N = 64;

    reg                   sm_valid_in;
    wire                  sm_valid_out;
    reg  [N*16-1:0]       in_x_flat_reg;   // 1024b
    wire [N*16-1:0]       prob_flat_wire;  // 1024b

    softmax #(.N(N)) u_softmax (
        .clk       (clk),
        .en        (1'b1),
        .rst       (rst),
        .valid_in  (sm_valid_in),
        .in_x_flat (in_x_flat_reg),
        .valid_out (sm_valid_out),
        .prob_flat (prob_flat_wire)
    );

    // 결과 워드 래치
    reg [15:0] y_word [0:N-1];

    // UART TX
    wire       tx_active;
    wire       tx_done;
    reg        tx_start;
    reg [7:0]  tx_byte;

    uart_tx u_tx (
        .clk              (clk),
        .baud_rate_select (BAUD_SEL),
        .start            (tx_start),
        .Byte_To_Send     (tx_byte),
        .Tx_Active        (tx_active),
        .Tx_Serial        (txd),
        .Tx_Done          (tx_done),
        .rst              (rst)
    );

    // 컨트롤러
    localparam integer WORDS       = 64;      // 64x16b
    localparam integer OUT_BYTES   = 128;     // 64*2

    localparam [3:0]
        S_WAIT_BLK  = 4'd0,
        S_PREP_ALL  = 4'd1,
        S_RD_LO     = 4'd2,
        S_RD_HI     = 4'd3,
        S_SM_PULSE  = 4'd4,
        S_SM_WAIT   = 4'd5,
        S_LATCH_OUT = 4'd6,
        S_TX_BYTES  = 4'd7,
        S_CONSUME   = 4'd8,
        S_WAIT_CLR  = 4'd9;

    reg [3:0] state;

    reg [5:0] widx;          // 0..63
    reg [7:0] tx_byte_idx;   // 0..127
    reg [7:0] base_addr;     // 0..127
    reg [7:0] lo_byte;       // LSB 임시 저장

    // tx_done 기반 페이싱
    reg       wait_tx_done;

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state         <= S_WAIT_BLK;

            widx          <= 6'd0;
            tx_byte_idx   <= 8'd0;
            base_addr     <= 8'd0;
            lo_byte       <= 8'd0;

            rd_addr       <= 7'd0;
            in_x_flat_reg <= {N*16{1'b0}};
            sm_valid_in   <= 1'b0;

            for (i=0; i<N; i=i+1) y_word[i] <= 16'd0;

            tx_start      <= 1'b0;
            tx_byte       <= 8'd0;
            wait_tx_done  <= 1'b0;

            consume       <= 1'b0;
        end else begin
            // 1클럭 펄스 기본값
            sm_valid_in <= 1'b0;
            tx_start    <= 1'b0;
            consume     <= 1'b0;

            case (state)
                // 128B 블록 대기
                S_WAIT_BLK: begin
                    if (block_ready) begin
                        state <= S_PREP_ALL;
                    end
                end

                // 64워드 결합 준비
                S_PREP_ALL: begin
                    widx      <= 6'd0;
                    base_addr <= 8'd0;       // 첫 워드 LSB 주소
                    rd_addr   <= 7'd0;       // 0
                    state     <= S_RD_LO;
                end

                // LSB 읽기
                S_RD_LO: begin
                    lo_byte <= rd_data;
                    rd_addr <= base_addr + 8'd1; // MSB 주소
                    state   <= S_RD_HI;
                end

                // MSB 읽고 {MSB,LSB} 결합
                S_RD_HI: begin
                    in_x_flat_reg[16*widx +: 16] <= {rd_data, lo_byte};
                    if (widx == (WORDS-1)) begin
                        state <= S_SM_PULSE;       // 모든 워드 채움
                    end else begin
                        widx      <= widx + 6'd1;
                        base_addr <= base_addr + 8'd2;
                        rd_addr   <= base_addr + 8'd2; // 다음 워드 LSB
                        state     <= S_RD_LO;
                    end
                end

                // Softmax 입력 유효(1클럭)
                S_SM_PULSE: begin
                    sm_valid_in <= 1'b1;
                    state       <= S_SM_WAIT;
                end

                // Softmax 결과 대기 (레이턴시 40은 valid_out으로 동기)
                S_SM_WAIT: begin
                    if (sm_valid_out) begin
                        state <= S_LATCH_OUT;
                    end
                end

                // 결과 64워드 래치
                S_LATCH_OUT: begin
                    for (i=0; i<N; i=i+1) begin
                        y_word[i] <= prob_flat_wire[16*i +: 16];
                    end
                    tx_byte_idx  <= 8'd0;
                    wait_tx_done <= 1'b0;
                    state        <= S_TX_BYTES;
                end

                // 128바이트 전송 (tx_done 기반)
                S_TX_BYTES: begin
                    if (!wait_tx_done) begin
                        // 아직 발사 전: TX가 비었으면 1바이트 발사
                        if (!tx_active) begin
                            if (tx_byte_idx[0] == 1'b0)
                                tx_byte <= y_word[tx_byte_idx[7:1]][7:0];   // LSB
                            else
                                tx_byte <= y_word[tx_byte_idx[7:1]][15:8];  // MSB
                            tx_start     <= 1'b1;   // 1클럭 펄스
                            wait_tx_done <= 1'b1;   // 완료 대기 상태로
                        end
                    end else begin
                        // 방금 보낸 바이트의 완료 대기
                        if (tx_done) begin
                            wait_tx_done <= 1'b0;   // 다음 발사 준비
                            if (tx_byte_idx == (OUT_BYTES-1)) begin
                                state <= S_CONSUME; // 128B 완료
                            end else begin
                                tx_byte_idx <= tx_byte_idx + 8'd1;
                            end
                        end
                    end
                end

                // 버퍼 소비(초기화) → 다음 128B 대기
                S_CONSUME: begin
                    consume <= 1'b1;
                    state   <= S_WAIT_CLR;
                end

                // block_ready 내려가면 다음 블록 대기
                S_WAIT_CLR: begin
                    if (!block_ready) state <= S_WAIT_BLK;
                end

                default: state <= S_WAIT_BLK;
            endcase
        end
    end
endmodule