`timescale 1ns/1ps

module approx_tb;

  reg [15:0] in_log2;
  wire [15:0] out_log2;

  reg signed [15:0] in_pow2;
  wire signed [15:0] out_pow2;

  log2_approx u_log2 (
      .in_x(in_log2),
      .log2_x(out_log2)
  );

  pow2_approx u_pow2 (
      .in_x(in_pow2),
      .pow2_x(out_pow2)
  );

  task display_fixed;
    input [15:0] val;
    real real_val;
    begin
      real_val = $itor($signed(val)) / 4096.0;
      $display("%h = %f", val, real_val);
    end
  endtask

  initial begin
    $display("==== log2_approx test ====");

    in_log2 = 16'b0001_1010_0000_0000;  // 1.625
    #10;
    $display("log2(1.625):");
    display_fixed(out_log2);

    in_log2 = 16'h2000;  // 2.0
    #10;
    $display("log2(2.0):");
    display_fixed(out_log2);

    in_log2 = 16'h4000;  // 4.0
    #10;
    $display("log2(4.0):");
    display_fixed(out_log2);

    in_log2 = 16'h0800;  // 0.5
    #10;
    $display("log2(0.5):");
    display_fixed(out_log2);

    $display("==== pow2_approx test ====");

    in_pow2 = 16'h0000;  // 0.0
    #10;
    $display("pow2(0.0):");
    display_fixed(out_pow2);

    in_pow2 = 16'b0001_1010_0000_0000;   // +1.625
    #10;
    $display("pow2(+1.0):");
    display_fixed(out_pow2);

    in_pow2 = 16'h2000;  // +2.0
    #10;
    $display("pow2(+2.0):");
    display_fixed(out_pow2);

    in_pow2 = 16'hF000;  // -1.0 (2's complement)
    #10;
    $display("pow2(-1.0):");
    display_fixed(out_pow2);

    $finish;
  end

endmodule