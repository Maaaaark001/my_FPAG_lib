`timescale 1ps/1ps
`default_nettype none

module TestCntSecMinHr;
    logic clk;
    logic rst;
    logic [5:0] sec, min;
    logic [4:0] hr;
    initial begin
        #0
            rst=1'b1;
        #1
            rst=1'b0;
    end
    initial begin
        #0
            clk=1'b0;
        forever  #5  clk=~clk;
    end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestCntSecMinHr );
    #2000000 $finish;
    end

    CntSecMinHr theCntSMH(clk, rst, sec, min, hr);
endmodule
