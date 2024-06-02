`timescale  1ns/1ns
`include "defines.sv"

module tb_master_slave();

    reg                         clk         ;
    reg                         rst_n       ;
    //reg                         mosi        ;
    reg     [`DATA_WIDTH-1:0]   data_i      ;
    reg                         start       ;
    reg                         miso        ;

    wire                        mosi        ;
    wire                        sclk        ;
    wire                        finish      ;
    wire                        ss_n        ;
    wire    [`DATA_WIDTH-1:0]   data_o      ;
    wire                        r_finish    ;

    SPI_MASTER u_spi_master (
        .clk    (clk)       ,
        .rst_n  (rst_n)     ,
        .miso   (miso)      ,
        .data_i (data_i)    ,
        .start  (start)     ,

        .mosi   (mosi)      ,
        .sclk   (sclk)      ,
        .finish (finish)    ,
        .ss_n   (ss_n)
    );

    SPI_SLAVE u_spi_slave(
        .clk    (clk)       ,
        .rst_n  (rst_n)     ,
        .mosi   (mosi)      ,
        .sclk   (sclk)      ,
        .tx_finish(finish),
        .start  (start)     ,
        .ss_n   (ss_n)      ,

        .data_o (data_o)    ,
        .r_finish(r_finish)
    );

    initial begin
         clk = 1'b0;
         rst_n = 1'b0;
         start = 1'b0;
         data_i = 8'h35;
         miso = 1'b0;
         #30
         rst_n = 1'b1;
         #10;
         @(posedge clk);
         start <= 1'b1;
         @(posedge clk);
         start <= 1'b0;
         @(negedge finish);
         data_i = 8'h44;
         repeat(2) @(posedge clk);
         start = 1'b1;
         @(posedge clk);
         start = 1'b0;
    end

    always #(`CLK_CYCLE / 2) clk = ~clk;
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_master_slave );
    #10000 $finish;
    end
endmodule

