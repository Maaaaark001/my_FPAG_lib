`timescale 1ps/1ps

module TestMux;
    //The original syntax is logic [7:0] a[4] = '{4{'0}};, which is not supported by iverilog.
    //So I wrote this initialization command in for form.
    logic [7:0] a[3:0];
    initial begin
        for(integer i = 0; i <4; i = i + 1) begin
            a[i] <= 0;
        end
    end
    logic [7:0] y;
	logic [1:0] sel = '0;
	always #10 a[0]++;
	always #20 a[1]++;
	always #40 a[2]++;
	always #80 a[3]++;
	always #160 sel++;
	Mux #(8, 4) theMux(a, sel, y);
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestMux);
    #10000 $finish;
    end
endmodule
