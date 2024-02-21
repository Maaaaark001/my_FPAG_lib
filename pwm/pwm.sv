`ifndef __PWM_SV__
`define __PWM_SV__

`default_nettype none

module Pwm #( parameter M = 256 )(
    input wire clk, rst,
    input wire [$clog2(M) - 1 : 0] data, // data range [0, M-1]
    output logic pwm, co
);
    logic [$clog2(M) - 1 : 0] cnt = '0;
    always_ff@(posedge clk) begin
        if(rst) cnt <= '0;
        else if(cnt < M - 1) cnt <= cnt + 1'd1;
        else cnt <= '0;
    end
    always_ff@(posedge clk) pwm <= (data > cnt);
    assign co = cnt == M - 1;
endmodule

module PwmSigned #( parameter M = 256 )(
    input wire clk, rst,
    input wire signed [$clog2(M) - 1 : 0] data,
    output logic pwm, co
);
    logic signed [$clog2(M) - 1 : 0] cnt = '0;
    always_ff@(posedge clk) begin
        if(rst) cnt <= '0;
        else if(cnt < M / 2 - 1) cnt <= cnt + 1'd1;
        else cnt <= -M / 2;
    end
    always_ff@(posedge clk) pwm <= (data > cnt);
    assign co = cnt == M / 2 - 1;
endmodule

module PwmDiffTime #( parameter M = 256 )(
    input wire clk, rst,
    input wire signed [$clog2(M) - 1 : 0] data,
    output logic pwm_p, pwm_n, co
);
    logic signed [$clog2(M) - 1 : 0] cnt = '0;
    always_ff@(posedge clk) begin
        if(rst) cnt <= '0;
        else if(cnt < M / 2 - 1) cnt <= cnt + 1'd1;
        else cnt <= -M / 2;
    end
    always_ff@(posedge clk) pwm_p <= (data > cnt);
    always_ff@(posedge clk) pwm_n <= (-data > cnt);
    assign co = cnt == M / 2 - 1;
endmodule

module PwmDiffFixedLow #( parameter M = 256 )(
    input wire clk, rst,
    input wire signed [$clog2(M) : 0] data, //data range [-M, M-1]
    output logic pwm_p, pwm_n, co
);
    logic [$clog2(M) - 1 : 0] cnt = '0;
    always_ff@(posedge clk) begin
        if(rst) cnt <= '0;
        else if(cnt < M - 1) cnt <= cnt + 1'd1;
        else cnt <= '0;
    end
    always_ff@(posedge clk) begin
        if(data >= 0) begin
            pwm_p <= (data > cnt);
            pwm_n <= '0;
        end
        else begin
            pwm_p <= '0;
            pwm_n <= (-data > cnt);
        end
    end
    assign co = cnt == M - 1;
endmodule

module RisingDelay #( parameter DELAY = 10 )(
    input wire clk, rst,
	input wire in,
    output logic out
);
    logic [$clog2(DELAY + 1) - 1 : 0] dly = '0;
	always_ff@(posedge clk) begin
		if(rst) dly = '0;
		else if(in) begin
			if(dly < DELAY) dly <= dly + 1'b1;
		end
		else dly <= '0;
	end
	assign out = dly == DELAY;
endmodule

`endif
