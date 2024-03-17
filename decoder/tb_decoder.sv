`timescale 1ns/1ns
`default_nettype none
module TestDecoder;
	logic [2:0] a = 5'b0;
	logic [7:0] y;
	always #10 a++;
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestDecoder );
    #200 $finish;
    end
	Decoder #(3) theDec(a, y);
endmodule
