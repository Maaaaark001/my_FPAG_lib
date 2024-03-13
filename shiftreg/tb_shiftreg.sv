`timescale 1ns/1ns
`default_nettype none
module TestShiftReg;
    logic clk;
    initial begin
        #0
            clk=1'b0;
        forever  #5  clk=~clk;
    end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestShiftReg );
    #150 $finish;
    end


endmodule
