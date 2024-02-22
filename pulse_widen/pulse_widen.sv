`default_nettype none
module PulseWiden #( parameter RATIO = 1 )(
	input wire clk, in,
	output logic out
);
	logic [$clog2(RATIO + 1) - 1 : 0] cnt = '0;
	always_ff@(posedge clk) begin
		if(in) cnt <= RATIO;
		else if(cnt > 0) cnt <= cnt - 1'b1;
	end
	assign out = cnt > 0;
endmodule
