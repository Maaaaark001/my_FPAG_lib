`timescale 1ns/1ns
`default_nettype none
module TestDDS;
    logic clk, rst;
    initial begin
        #0
            clk=1'b0;
        forever  #50  clk=~clk;
    end
    initial begin
        rst = 1;
        #60 rst =0;
    end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestDDS );
    #1000000 $finish;
    end
    real freqr = 1e6, fstepr = 49e6/(1e-3*100e6); // from 1MHz to 50MHz in 1ms
    always@(posedge clk) begin
        if(rst) freqr = 1e6;
        else freqr += fstepr;
    end
    logic signed [31:0] freq;
    always@(posedge clk) begin
        freq <= 2.0**32 * freqr / 100e6; // frequency to freq control word
    end
    logic signed [31:0] phase = '0;
    logic signed [9:0] swave;
    DDS #(32, 10, 13) theDDS(clk, rst, 1'b1, freq, phase, swave);
endmodule
