`timescale 1ps/1ps
`default_nettype none

module TestPwm;
    logic clk, rst;
    initial begin
        #0
            rst=1'b1;
        #2
            rst=1'b0;
    end
    initial begin
        #0
            clk=1'b0;
        forever  #5  clk=~clk;
    end
    logic [3:0] udata = '0;
    logic signed [3:0] sdata = '0;
    logic signed [3:0] sdata_dt = '0;
    logic signed [4:0] sdata_fl = '0;
    logic co, co_s, co_dt, co_fl;
    always@(posedge clk) if(co) udata++;
    always@(posedge clk) if(co_s) sdata++;
    always@(posedge clk) if(co_dt) sdata_dt++;
    always@(posedge clk) if(co_fl) sdata_fl++;
    logic pwm, pwm_s, pwm_dt_p, pwm_dt_n, pwm_fl_p, pwm_fl_n;
    Pwm             #(16) thePwm  (clk, rst, udata,    pwm, co);
    PwmSigned       #(16) thePwmS (clk, rst, sdata,    pwm_s, co_s);
    PwmDiffTime     #(16) thePwmDt(clk, rst, sdata_dt, pwm_dt_p, pwm_dt_n, co_dt);
    PwmDiffFixedLow #(16) thePwmFl(clk, rst, sdata_fl, pwm_fl_p, pwm_fl_n, co_fl);
	logic pwm_up, pwm_lo;
	RisingDelay #(2) dtUp(clk, rst,  pwm, pwm_up);
	RisingDelay #(2) dtLo(clk, rst, ~pwm, pwm_lo);
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestPwm );
    #10000 $finish;
    end
endmodule
