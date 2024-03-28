`timescale 1ns/1ns
`default_nettype none
`include "../dds/dds.sv"
`include "../counter/counter.sv"
module TestFir;
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
        $dumpvars(0, TestFir );
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
    logic signed [9:0] filtered, harm3;
    logic square = '0, en15;
    Counter #(15) cnt15(clk, rst, 1'b1, , en15);
    always_ff@(posedge clk) if(en15) square <= ~square;
    FIR #(10, 27, '{ -0.005646,  0.006428,  0.019960,  0.033857,  0.036123,
                      0.016998, -0.022918, -0.068988, -0.097428, -0.087782,
                     -0.036153,  0.039431,  0.106063,  0.132519,  0.106063,
                      0.039431, -0.036153, -0.087782, -0.097428, -0.068988,
                     -0.022918,  0.016998,  0.036123,  0.033857,  0.019960,
                      0.006428, -0.005646
    })  theFir1(clk, rst, 1'b1, 10'(integer'(swave * 0.9)), filtered),
        theFir2(clk, rst, 1'b1, square ? 10'sd500 : -10'sd500, harm3);
endmodule
