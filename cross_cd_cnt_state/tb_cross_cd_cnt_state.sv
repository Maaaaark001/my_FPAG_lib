`timescale 1ns/1ns
`default_nettype none
module TestCCCnt;
    logic clk_a, clk_b;
    initial begin
        #2
            clk_a=1'b0;
        forever  #5  clk_a=~clk_a;
    end
    initial begin
        #1
            clk_b=1'b0;
        forever  #4.5  clk_b=~clk_b;
    end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestCCCnt );
    #200 $finish;
    end
    logic inc = 0;
    always #10 inc = $random();
	logic [7:0] cnt_a, cnt_b;
    CrossClkCnt theCCCnt(clk_a, clk_b, inc, cnt_a, cnt_b);
endmodule
