`timescale 1ns/1ns
`default_nettype none
module TestEdge2En;
    logic clk;
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
    logic en1, en2, enR, enF;
    logic out1, out2, outRF;
    //Rising2En #(1) theR2E0(clk, in, en0, );
    Rising2En theR2E1(clk, in, en1, out1);
    Rising2En #(2) theR2E2(clk, in, en2, out2);
    Edge2En #(1) theEd2E(clk, in, enR, enF, outRF);
endmodule
