`timescale 1ns/1ns
`default_nettype none
module TestDelayChain;
	logic [7:0] a, y;
	logic clk;
	logic rst;
	initial begin
        #0
            clk=1'b0;
        forever  #5  clk=~clk;
    end
    initial begin
        #5
            rst=1;
        #5
            rst=0;
    end
	initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestDelayChain  );
    #200 $finish;
    end
	always #10 a = $random();
	DelayChain #(8,1) dc(clk, rst, 1'b1, a, y);
endmodule
