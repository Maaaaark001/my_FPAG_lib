`ifndef __COUNTER_SV__
`define __COUNTER_SV__

`default_nettype none


module CntSecMinHr(
    input wire clk, rst,
    output logic [5:0] sec,
    output logic [5:0] min,
    output logic [4:0] hr
);
    logic en1sec, en1min, en1hr;
    Counter #(10) cnt1sec (.clk(clk), .rst(rst), .en(  1'b1), .cnt(),    .co(en1sec));
    Counter #(60) cnt60sec(.clk(clk), .rst(rst), .en(en1sec), .cnt(sec), .co(en1min));
    Counter #(60) cnt60min(.clk(clk), .rst(rst), .en(en1min), .cnt(min), .co(en1hr ));
    Counter #(24) cnt24hr (.clk(clk), .rst(rst), .en(en1hr ), .cnt(hr ), .co());
endmodule

module Counter #(
    parameter M = 100
)(
    input wire clk, rst, en,
    output logic [$clog2(M) - 1 : 0] cnt,
    output logic co
);
    assign co = en & (cnt == M - 1);
    always_ff@(posedge clk) begin
        if(rst) cnt <= '0;
        else if(en) begin
            if(cnt < M - 1) cnt <= cnt + 1'b1;
            else cnt <= '0;
        end
    end
endmodule

module CounterMax #(
    parameter DW = 8
)(
    input wire clk, rst, en,
    input wire [DW - 1 : 0] max,
    output logic [DW - 1 : 0] cnt,
    output logic co
);
    assign co = en & (cnt == max);
    always_ff@(posedge clk) begin
        if(rst) cnt <= '0;
        else if(en) begin
            if(cnt < max) cnt <= cnt + 1'b1;
            else cnt <= '0;
        end
    end
endmodule

`endif
