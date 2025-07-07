`timescale 1ns/1ps

module RU_tb;

  // Inputs
  reg signed [15:0] in_0;
  reg signed [15:0] in_1;
  reg sel_mult;
  reg sel_mux;

  // Outputs
  wire signed [15:0] out_0;
  wire signed [15:0] out_1;

  // DUT
  RU uut (
      .in_0(in_0),
      .in_1(in_1),
      .sel_mult(sel_mult),
      .sel_mux(sel_mux),
      .out_0(out_0),
      .out_1(out_1)
  );

  // Utility task to print fixed-point Q4.12 as real
  task display_fixed;
    input [15:0] val;
    real real_val;
    begin
      real_val = $itor($signed(val)) / 4096.0;
      $display("%h = %f", val, real_val);
    end
  endtask

  initial begin
    $display("=== RU Module Test Start ===");

    // Stage 1 test
    $display("Stage 1: (x_i - max) * log2(e)");
    in_0 = 16'h2400;  // max = 2.25
    in_1 = 16'h1000;  // x_i = 1.0
    sel_mux = 1;      // Stage 1
    sel_mult = 1;     // log2(e)
    #10;
    $display("-- Stage 1 output --");
    $display("Input x_i ="); display_fixed(in_1);
    $display("Input max ="); display_fixed(in_0);
    $display("out_0 (mult result) ="); display_fixed(out_0);
    $display("out_1 (pow2 approx) ="); display_fixed(out_1);
    $display("");

    // Stage 2 test
    $display("Stage 2: (log2_sum - y_i) * 1");
    in_0 = 16'h1800;  // sum ≈ 3.0
    in_1 = 16'b1110_0011_0001_0110;  // y_i ≈ 1.5
    sel_mux = 0;      // Stage 2
    sel_mult = 0;     // multiply by 1.0
    #10;
    $display("-- Stage 2 output --");
    $display("Input sum ="); display_fixed(in_0);
    $display("Input y_i ="); display_fixed(in_1);
    $display("out_0 (diff) ="); display_fixed(out_0);
    $display("out_1 (pow2 approx) ="); display_fixed(out_1);
    $display("");

    $display("=== RU Module Test End ===");
    $finish;
  end

endmodule