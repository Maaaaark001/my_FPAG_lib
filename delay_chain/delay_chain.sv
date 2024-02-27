`ifndef __DELAY_CHAIN_SV__
`define __DELAY_CHAIN_SV__
`default_nettype none
module DelayChain #(
	parameter DW = 8,
	parameter LEN = 4
)(
    input wire clk, rst, en,
    input wire [DW - 1 : 0] in,
    output logic [DW - 1 : 0] out
);
    generate
        if(LEN == 0) begin
            assign out = in;
        end
        else if(LEN == 1) begin
            logic [DW - 1 : 0] dly;
            always_ff@(posedge clk) begin
                if(rst) dly = '0;
                else if(en) dly <= in;
            end
            assign out = dly;
        end
        else begin
            logic [DW - 1 : 0] dly[0 : LEN - 1];
            always_ff@(posedge clk) begin
                if(rst) begin
                for(integer i = 0; i <LEN; i = i + 1) begin
	                dly[i] <= 0;
                end
                end
                else if(en) begin
                for(integer i = 0; i <LEN; i = i + 1) begin
	                dly[0 : LEN - 1] <= {in, dly[0 : LEN - 2]};
                end
                end
            end
            assign out = dly[LEN - 1];
        end
    endgenerate
endmodule

`endif
