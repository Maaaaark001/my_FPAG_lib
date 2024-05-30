`timescale 1 ns/ 1 ns
//------------<模块及端口声明>----------------------------------------
module frequency_conter_test();

reg clk_fs;
reg clk_fx;
reg rst_n;

wire [63:0]  fre;

//------------<例化被测试模块>----------------------------------------
frequency_conter frequency_conter_inst (
	.clk_fs		(clk_fs	)	,
	.clk_fx		(clk_fx	)	,
	.fre		(fre	)	,
	.rst_n		(rst_n	)
);
//------------<设置初始测试条件>----------------------------------------
initial	begin
	clk_fs = 1'b0;
	clk_fx <= 1'b0;
	rst_n <= 1'b0;
	#116
	rst_n <= 1'b1;

end
//------------<设置时钟>----------------------------------------------
always	#10 clk_fs <= ~clk_fs;
always  #489 clk_fx <= ~clk_fx;

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, frequency_conter_test);
#1000000 $finish;
end

endmodule
