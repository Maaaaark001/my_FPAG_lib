`default_nettype none
module Mux #(
	parameter DW = 8,
	parameter CH = 4
)(
	input wire [DW - 1 : 0] in[CH:0],
	input wire [$clog2(CH) - 1 : 0] sel,
	output logic [DW - 1 : 0] out
);
	assign out = in[sel];
endmodule
