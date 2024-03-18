`timescale 1ns/1ns
`default_nettype none
module TestEncoder;
	logic [7:0] a = 5'b0;
	logic [2:0] y;
	always #10 a++;
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestEncoder );
    #150 $finish;
    end
	Encoder #(3) theEnc(a, y);
endmodule
