module Encoder #(
	parameter OUTW = 4
)(
	input wire [2**OUTW - 1 : 0] in,
	output logic [OUTW - 1 : 0] out
);
	always_comb begin
		out = '0;
		for(integer i = 2**OUTW - 1; i >= 0; i--) begin
			if(in[i]) out = OUTW'(i);
		end
	end
endmodule

