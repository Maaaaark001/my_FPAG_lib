`ifndef __SCFIFO_SV__
`define __SCFIFO_SV__

`include "../memory/memory.sv"

`default_nettype none



module ScFifo1 #(		// add rst in 20220315
	parameter DW = 8,
	parameter AW = 10
)(
	input wire clk, rst,
	input wire [DW - 1 : 0] din,
	input wire write,
	output logic [DW - 1 : 0] dout,
	input wire read,
	output logic [AW - 1 : 0] wr_cnt, rd_cnt ,
    output logic [AW - 1 : 0] data_cnt,
	output logic full, empty
);
	initial begin
		wr_cnt=0;
		rd_cnt=0;
	end
	localparam CAPACITY = 2**AW - 1;
	always_ff@(posedge clk) begin
		if(rst)        wr_cnt <= '0;
		else if(write) wr_cnt <= wr_cnt + 1'b1;
	end
	always_ff@(posedge clk) begin
		if(rst)       rd_cnt <= '0;
		else if(read) rd_cnt <= rd_cnt + 1'b1;
	end
	assign data_cnt = wr_cnt - rd_cnt;
	assign full = data_cnt == CAPACITY;
	assign empty = data_cnt == 0;
	SdpRamRf #(.DW(DW), .WORDS(2**AW)) theRam(
        .clk(clk), .addr_a(wr_cnt), .wr_a(write),
        .din_a(din), .addr_b(rd_cnt), .qout_b(dout)
	);
endmodule

module ScFifo2 #(		// add rst in 20220315
	parameter DW = 8,
	parameter AW = 10
)(
	input wire clk, rst,
	input wire [DW - 1 : 0] din,
	input wire write,
	output logic [DW - 1 : 0] dout,
	input wire read,
	output logic [AW - 1 : 0] wr_cnt, rd_cnt,
    output logic [AW - 1 : 0] data_cnt,
	output logic full, empty
);
	initial begin
		wr_cnt=0;
		rd_cnt=0;
	end
	localparam CAPACITY = 2**AW - 1;
	always_ff@(posedge clk) begin
		if(rst)        wr_cnt <= 1'b0;
		else if(write) wr_cnt <= wr_cnt + 1'b1;
	end
	always_ff@(posedge clk) begin
		if(rst)       rd_cnt <= 1'b0;
		else if(read) rd_cnt <= rd_cnt + 1'b1;
	end
	assign data_cnt = wr_cnt - rd_cnt;
	assign full = data_cnt == CAPACITY;
	assign empty = data_cnt == 0;
	logic rd_dly;
	always_ff@(posedge clk) begin
		if(rst) rd_dly <= 1'b0;
		else    rd_dly <= read;
	end
	logic [DW - 1 : 0] qout_b, qout_b_reg = '0;
	always_ff@(posedge clk) begin
		if(rst)         qout_b_reg <= '0;
		else if(rd_dly) qout_b_reg <= qout_b;
	end
	SdpRamRf #(.DW(DW), .WORDS(2**AW)) theRam(
        .clk(clk), .addr_a(wr_cnt), .wr_a(write),
        .din_a(din), .addr_b(rd_cnt), .qout_b(qout_b)
	);
	assign dout = (rd_dly)? qout_b : qout_b_reg;
endmodule

module ScFifoSA #(	// output show-ahead(altera's term) or FWFT(xilinx's term)  // add rst in 20220315
	parameter DW = 8,
	parameter AW = 10
)(
	input wire clk, rst,
	input wire [DW - 1 : 0] din,
	input wire write,
	output logic [DW - 1 : 0] dout,
	input wire read,
	output logic [AW - 1 : 0] wr_cnt, rd_cnt,
    output logic [AW - 1 : 0] data_cnt,
	output logic full, empty
);
	initial begin
		wr_cnt=0;
		rd_cnt=0;
	end
	localparam CAPACITY = 2**AW - 1;
	always_ff@(posedge clk) begin
		if(rst)        wr_cnt <= '0;
		else if(write) wr_cnt <= wr_cnt + 1'b1;
	end
	always_ff@(posedge clk) begin
		if(rst)       rd_cnt <= '0;
		else if(read) rd_cnt <= rd_cnt + 1'b1;
	end
	assign data_cnt = wr_cnt - rd_cnt;
	assign full = data_cnt == CAPACITY;
	assign empty = data_cnt == 0;
	SdpRamRa #(.DW(DW), .WORDS(2**AW)) theRam(
        .clk(clk), .addr_a(wr_cnt), .wr_a(write),
        .din_a(din), .addr_b(rd_cnt), .qout_b(dout)
	);
endmodule

`endif
