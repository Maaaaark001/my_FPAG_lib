`timescale 1ns/1ns
`default_nettype none
module uart_loop_tb;
    reg clk_sys;
    reg rst_n;
    reg uart_in;
    wire uart_out;
    wire parity;

    uart_loop u_uart_loop(
        .i_clk_sys(clk_sys),
        .i_rst_n(rst_n),
        .i_uart_rx(uart_in),
        .o_uart_tx(uart_out),
        .o_ld_parity(parity)
        );


    initial begin
        clk_sys = 1'b0;
        rst_n = 1'b0;
        uart_in = 1'b1;
    end

    always #10 clk_sys = ~clk_sys;

    localparam ELEMENT_TIME = 104160;
    reg [7:0] DATA = 8'hAC;

    initial begin
        #100 rst_n = 1'b1;
        #20000;

        uart_in = 1'b0;
        #ELEMENT_TIME
        uart_in = DATA[0];
        #ELEMENT_TIME
        uart_in = DATA[1];
        #ELEMENT_TIME
        uart_in = DATA[2];
        #ELEMENT_TIME
        uart_in = DATA[3];
        #ELEMENT_TIME
        uart_in = DATA[4];
        #ELEMENT_TIME
        uart_in = DATA[5];
        #ELEMENT_TIME
        uart_in = DATA[6];
        #ELEMENT_TIME
        uart_in = DATA[7];
        #ELEMENT_TIME
        uart_in = 1'b1;
        #ELEMENT_TIME
        uart_in = 1'b1;

    end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, uart_loop_tb );
    #3000000 $finish;
    end
endmodule
