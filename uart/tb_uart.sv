`timescale 1ns/1ns
`default_nettype none
`include "../counter/counter.sv"
`include "../edge2en/edge2en.sv"
`include "../scfifo/scfifo.sv"
module TestUart;
    logic clk, rst;
    initial begin
        #0
            clk=1'b0;
        forever  #5  clk=~clk;
    end
    initial begin
        #0
            rst=1'b1;
        #11
            rst=1'b0;
    end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TestUart );
    #100000 $finish;
    end
    logic [7:0] tx_fifo_din, tx_fifo_dout;
    logic [8:0] rx_fifo_din, rx_fifo_dout;
    logic tx_fifo_write = '0, tx_fifo_read, tx_fifo_empty;
    logic rx_fifo_write, rx_fifo_read = '0;
    logic [3:0] rx_fifo_dc;
    ScFifo2 #(8, 4) theTxFifo(
        clk, rst, tx_fifo_din, tx_fifo_write, tx_fifo_dout, tx_fifo_read,
         , , , , tx_fifo_empty);
    ScFifo2 #(9, 4) theRxFifo(
        clk, rst, rx_fifo_din, rx_fifo_write, rx_fifo_dout, rx_fifo_read,
         , , rx_fifo_dc, , );
    logic start, uart, tx_busy, rx_busy, par_err;
    assign tx_fifo_read = ~tx_fifo_empty & ~tx_busy & ~start;
    always_ff@(posedge clk) start <= tx_fifo_read;
    UartTx #(108, 1) theUartTx(clk, rst,
        tx_fifo_dout, start, tx_busy, uart);
    UartRx #(109, 1) theUartRx(clk, rst,
        uart, rx_fifo_din[7:0], rx_fifo_write, rx_fifo_din[8], rx_busy);
    initial begin
        repeat(100) @(posedge clk);
        @(posedge clk) {tx_fifo_write, tx_fifo_din} = {1'b1, 8'ha5};
        @(posedge clk) {tx_fifo_write, tx_fifo_din} = {1'b1, 8'hc3};
        @(posedge clk) tx_fifo_write = 1'b0;
        repeat(2500) @(posedge clk);
        @(posedge clk) {tx_fifo_write, tx_fifo_din} = {1'b1, 8'h37};
        @(posedge clk) tx_fifo_write = 1'b0;
    end
    initial begin
        wait(rx_fifo_dc >= 4'd3);
        repeat(3) begin
            @(posedge clk) rx_fifo_read = 1'b1;
        end
        @(posedge clk) rx_fifo_read = 1'b0;
        repeat(100) @(posedge clk);
    end
endmodule
