`timescale 1ns/1ns
`default_nettype none
module TestCordic;
    logic clk, rst;
    initial begin
        #1
            clk=1'b0;
        forever  #50  clk=~clk;
    end
    initial begin
        rst=1;
        #80 rst = 0;
    end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestCordic );
    #10000 $finish;
    end
    logic signed [9:0] ang = '0, cos, sin, arem;
    always_ff@(posedge clk) begin
        if(rst) ang <= '0;
        else ang <= ang + 1'b1;
    end
    Cordic #(10) theCordic(clk, rst, 1'b1, 10'sd500, 10'sd0, ang, cos, sin, arem);
endmodule
