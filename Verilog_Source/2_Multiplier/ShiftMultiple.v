module Multiplier_shift #(parameter N = 8)(
    input wire [N-1:0] multiplicand,
    input wire [N-1:0] multiplier,
    input wire clk,
    input wire rst,
    input wire en,
    output wire [(2*N)-1:0] product
);
    reg [(2*N):0] temp;
    wire [N:0] sum;

    CLA #(.N(N))adder(
        .C_in(0),
        .x(multiplicand & {N{temp[0]}}),
        .y(temp[2*N-1:N]),
        .sum(sum[N-1:0]),
        .C_out(sum[N])
    );

    always @(posedge clk) begin
        if (rst) begin
            temp<={{(N+1){1'b0}}, multiplier};
        end
        else if (en) begin
            temp <= {1'b0, sum, temp[N-1:1]};
        end
    end
    assign product = temp[(2*N)-1:0];
endmodule