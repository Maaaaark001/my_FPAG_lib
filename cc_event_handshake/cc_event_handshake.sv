module CrossClkEvent (
	input wire clk_a, clk_b,
	input wire in,     // domain a
	output logic busy, // domain a
	output logic out   // domain b
);
	logic ra0 = '0, ra1 = '0, ra2 = '0;
	logic rb0 = '0, rb1 = '0, rb2 = '0;
	// === clk_a domain ===
	always_ff@(posedge clk_a) begin
		if(in) ra0 <= 1'b1;
		else if(ra2) ra0 <= 1'b0;
	end
	always_ff@(posedge clk_a) begin
		{ra2, ra1} <= {ra1, rb1};
	end
	assign busy = ra0 | ra2;
	// === clk_b domain ===
	always_ff@(posedge clk_b) begin
		{rb2, rb1, rb0} <= {rb1, rb0, ra0};
	end
	assign out = rb1 & ~rb2;
endmodule
