`timescale 1ns/100ps
`default_nettype none
module TestIis;
    logic clk;
    initial begin
        #10
            clk=1'b0;
        forever  #40.69ns  clk=~clk;
    end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestIis );
    #100000 $finish;
    end
    // ==== transmitter side ====
    logic sck, ws, sd, sck_fall, f_sync, txdata_rd;
    // sck 3.072M, ws 48k
    IisClkGen #(64, 8) iisClk(clk, sck, ws, sck_fall, f_sync);
    logic signed [31:0] txdata[2];
    IisTransmitter iisTrans(clk, sck_fall, f_sync, txdata, txdata_rd, sd);
    // ==== receiver side ====
    logic signed [31:0] rxdata[2];
    logic rxdata_valid;
    IisReceiver iisRecv(clk, sck, ws, sd, rxdata, rxdata_valid);
    // ==== transmitter side data ====
    always_ff@(posedge clk) begin
        if(txdata_rd) begin
            txdata[0] <= $random() ;
            txdata[1] <= $random() ;
        end
    end

endmodule
