`timescale 1ns/1ns
`default_nettype none
module TestPulseWiden;
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
		#100 in = 1;
		#10 in = 0;
	end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestPulseWiden );
    #400 $finish;
    end
	logic out, out2, out3;
	PulseWiden #(4) pw1(clk, in, out);
	PulseWiden #(2) pw2(clk, in, out2);
	PulseWiden #(3) pw3(clk, in, out3);
endmodule
