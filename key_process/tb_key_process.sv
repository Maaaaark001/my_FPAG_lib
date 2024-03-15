`timescale 1ns / 10ps
`default_nettype none
module TestKeyProcess;
  logic clk;
  initial begin
    #0 clk = 1'b0;
    forever #0.05  clk = ~clk;
  end
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, TestKeyProcess);
    #150 $finish;
  end
  logic key = '0, key_en;
  initial begin
    #10;
    for (int i = 0; i < 30; i++) begin
      #0.13 key = '0;
      #0.12 key = '1;
    end
    #40 key = '0;
  end
  initial begin
    #80;
    for (int i = 0; i < 30; i++) begin
      #0.13 key = '0;
      #0.12 key = '1;
    end
    #40 key = '0;
  end
  KeyProcess #(100, 1) theKeyProc (
      clk,
      key,
      key_en
  );
endmodule
