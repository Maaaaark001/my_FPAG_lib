`ifndef __PID_SV__
`define __PID_SV__

`include "../common.sv"

module Pid #(
    parameter W = 32, FW = 16,
    parameter real P = 8, real I = 192, real D = 0,
    parameter real N = 100, real TS = 0.002,
    parameter real LIMIT = 10000
)(
    input wire clk, rst, en,
    input wire signed [W-1:0] in,
    output logic signed [W-1:0] out
);
    import Fixedpoint::*;
    wire signed [W-1:0] p = P * (2.0 ** FW);
    wire signed [W-1:0] i = (I * TS) * (2.0 ** FW);
    wire signed [W-1:0] d = D * (2.0 ** FW);
    wire signed [W-1:0] n = N * (2.0 ** FW);
    wire signed [W-1:0] ts = TS * (2.0 ** FW);
    wire signed [W-1:0] lim = LIMIT * (2.0 ** FW);
    `DEF_FP_MUL(mul, W-FW, FW, W-FW, FW, FW);
    wire signed [W-1:0] xp = mul(in, p);
    wire signed [W-1:0] xi = mul(in, i);
    logic signed [W-1:0] xi_acc;
    always_ff@(posedge clk) begin
        if(rst) xi_acc <= 1'sb0;
        else if(en) begin
            if(xi_acc + xi > lim) xi_acc <= lim;
            else if(xi_acc + xi < -lim) xi_acc <= -lim;
            else xi_acc <= xi_acc + xi;
        end
    end
    logic signed [W-1:0] dacc; 
    wire signed [W-1:0] xd  = mul(in, d);
    wire signed [W-1:0] xnd = mul((xd - dacc), n);   
    wire signed [W-1:0] tnd = mul(xnd, ts);
    always_ff@(posedge clk) begin
        if(rst) dacc <= 1'sb0;
        else if(en) begin
            if(dacc + tnd > lim) dacc = lim;
            else if(dacc + tnd < -lim) dacc = -lim;
            else dacc <= dacc + tnd;
        end
    end
    always_ff@(posedge clk) begin
        if(rst) out <= 1'sb0;
        else if(en) out <= xp + xi_acc + xnd;
    end
endmodule

`endif
