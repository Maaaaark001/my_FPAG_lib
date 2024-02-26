`timescale 1ns/1ns
`default_nettype none
module TestScFifo;
	logic clk;
	initial begin
        #0
            clk=1'b0;
        forever  #5  clk=~clk;
    end
	logic [7:0] din = '0, dout;
	logic wr = '0, rd = '0;
	logic [2:0] wc, rc, dc;
	logic fu, em;
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestScFifo );
    #1000 $finish;
    end
	initial begin
		for(int i = 0; i < 10; i++) begin
			@(posedge clk) {wr, din} = {1'b1, 8'($random())};
		end
		@(posedge clk) wr = 1'b0;
		for(int i = 0; i < 10; i++) begin
			@(posedge clk) rd = 1'b1;
		end
		@(posedge clk) rd = 1'b0;
		for(int i = 0; i < 5; i++) begin
			@(posedge clk) {wr, din} = {1'b1, 8'($random())};
		end
		@(posedge clk) wr = 1'b0;
		for(int i = 0; i < 5; i++) begin
			@(posedge clk) rd = 1'b1;
		end
		@(posedge clk) rd = 1'b0;
		for(int i = 0; i < 5; i++) begin
			@(posedge clk) {wr, din} = {1'b1, 8'($random())};
		end
		@(posedge clk) wr = 1'b0;
		for(int i = 0; i < 5; i++) begin
			@(posedge clk) rd = 1'b1;
		end
		@(posedge clk) rd = 1'b0;
		//#10 $stop();
	end
	ScFifo2 #(8, 3) theFifo(clk, 1'b0, din, wr & ~fu, dout, rd & ~em, wc, rc, dc, fu, em);
endmodule
