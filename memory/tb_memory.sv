`timescale 1ns/1ns
`default_nettype none
module TestMem;
    logic clk;
    initial begin
        #0
            clk=1'b0;
        forever  #5  clk=~clk;
    end
    logic [7:0] a = 0, d = 0, q;
    logic we = 0;
        initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestMem );
    #1000 $finish;
    end
    initial begin
        #10 {we, a, d} = {1'b1, 8'h01, 8'h10};
        #10 {we, a, d} = {1'b1, 8'h03, 8'h30};
        #10 {we, a, d} = {1'b1, 8'h06, 8'h60};
        #10 {we, a, d} = {1'b1, 8'h0a, 8'ha0};
        #10 {we, a, d} = {1'b1, 8'h0f, 8'hf0};
        #10 {we, a, d} = {1'b0, 8'h00, 8'h00};
        forever #10 a++;
    end
    SpRamRfSine theMem(clk, a, we, d, q);
endmodule
