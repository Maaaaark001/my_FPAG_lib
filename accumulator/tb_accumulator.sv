`timescale 1ns/1ns
`default_nettype none
module TestAccu;
    logic clk,rst;
    initial begin
        #0
            clk=1'b0;
        forever  #5  clk=~clk;
    end
    initial begin
        #0
            rst=1;
        #10  rst=0;
    end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestAccu );
    #1000 $finish;
    end
    logic [15:0] d = '0, acc;
    always #10 d++;
    Accumulator #(16) theAcc(clk, rst, 1'b1, d, acc);
    logic [5:0] dm = '0, accm;
    always #10 dm++;
    AccuM #(50) theAccM(clk, rst, 1'b1, dm, accm);
endmodule
