`timescale 1ns/1ns
`default_nettype none
module TestCCEvent;
    logic clk_a, clk_b;
    initial begin
        #2
            clk_a=1'b0;
        forever  #5  clk_a=~clk_a;
    end
    initial begin
        #1
            clk_b=1'b0;
        forever  #6  clk_b=~clk_b;
    end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestCCEvent );
    #500 $finish;
    end
    logic in = 0;
	initial begin
		#100 in = 1;
		#10 in = 0;
		#80 in = 1;
		#10 in = 0;
	end
	logic busy, out;
    CrossClkEvent theCCEvent(clk_a, clk_b, in, busy, out);
endmodule
