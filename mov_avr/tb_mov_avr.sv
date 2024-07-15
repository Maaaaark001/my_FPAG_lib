`timescale 1ns/1ns
`default_nettype none
// This module is a simple testbench for the moving average filter with a configurable number of stages.

module TestMovAvr;
    logic clk,rst_n;
    initial begin
        #0
            clk=1'b0;
        forever  #5  clk=~clk;
    end
    logic in;
    initial begin
        in = 0;
        #44 in = 1;
        #56 in = 0;
    end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestEdge2En );
    #150 $finish;
    end
    MovAvr newMovAvr(clk,rst_n,1,in,avr,ac);
endmodule
