`timescale 1ps/1ps
`default_nettype none

module TestCounter;
    logic clk;
    logic rst;
    logic en;
    initial begin
        #0
            rst=1'b1;
        #20
            rst=1'b0;
    end
    initial begin
        #0
            clk=1'b0;
        forever  #5  clk=~clk;
    end
    initial begin
        en = 1'b1;
        #100 en = 1'b0;
        #100 en = 1'b1;
    end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestCounter );
    #20000 $finish;
    end
    logic [6:0] cnt;
    logic co;
    Counter #(128) theCnt(clk, rst, en, cnt, co);
endmodule
