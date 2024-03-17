module CrossClkCnt #( parameter W = 8 )(
	input wire clk_a, clk_b, inc,
	output logic [W - 1 : 0] cnt_a = '0,output reg [W - 1 : 0] cnt_b
);
	// === clk_a domain ===
	logic [W - 1 : 0] bin_next;
	logic [W - 1 : 0] gray, gray_next;
	always_comb begin
		bin_next = cnt_a + inc;
		gray_next = bin_next ^ (bin_next >> 1);
	end
	always_ff@(posedge clk_a) begin
		cnt_a <= bin_next;
		gray <= gray_next;
	end
	// === clk_b domain ===
	logic [W - 1 : 0] gray_sync[2];
	always_ff@(posedge clk_b) begin
		gray_sync[1] <= gray_sync[0];
		gray_sync[0] <= gray;
	end
	always_comb begin
		for(int i = 0; i < W; i++)
			cnt_b[i] = ^(gray_sync[1] >> i);
	end
endmodule
