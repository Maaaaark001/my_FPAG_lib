`timescale 1ns/1ns
`default_nettype none
`include "../dds/dds.sv"
`include "../counter/counter.sv"
module TestIir;
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
        $dumpvars(0, TestIir );
    #1000000 $finish;
    end
    real freqr = 1e6, fstepr = 49e6/(1e-3*100e6); // from 1MHz to 50MHz in 1ms
    always@(posedge clk) begin
        if(rst) freqr = 1e6;
        else freqr += fstepr;
    end
    logic signed [31:0] freq;
    always@(posedge clk) begin
        freq <= 2.0**32 * freqr / 100e6; // freq control word
    end
    logic signed [31:0] phase = '0;
    logic signed [9:0] swave;
    DDS #(32, 10, 13) theDDS(clk, rst, 1'b1, freq, phase, swave);
    logic signed [9:0] filtered, harm3;
    logic square = '0, en15;
    Counter #(15) cnt15(clk, rst, 1'b1, , en15);
    always_ff@(posedge clk) if(en15) square <= ~square;
    IIR #(10, 5, 3, '{ 0.262748, 0.262748, 0.060908 }, // GAIN
        '{  '{ 1, -1.368053,  1       },               // s0:NUM
            '{ 1, -1.779618,  1       },               // s1:NUM
            '{ 1,  0       , -1       } },             // s2:NUM
        '{  '{    -1.519556,  0.969571},               // s0:DEN
            '{    -1.665517,  0.974258},               // s1:DEN
            '{    -1.569518,  0.936203} }              // s2:DEN
    )  theIir1(clk, rst, 1'b1, 10'(integer'(swave * 0.9)), filtered),
        theIir2(clk, rst, 1'b1, square?10'sd500:-10'sd500, harm3);
endmodule
