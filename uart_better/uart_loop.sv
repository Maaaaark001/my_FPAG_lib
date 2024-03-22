module uart_loop (
    input  i_clk_sys,
    input  i_rst_n,
    input  i_uart_rx,
    output o_uart_tx,
    output o_ld_parity
);

  localparam DATA_WIDTH = 8;
  localparam BAUD_RATE = 9600;
  localparam PARITY_ON = 1;
  localparam PARITY_TYPE = 1;

  wire w_rx_done;
  wire [DATA_WIDTH-1 : 0] w_data;


  uart_rx #(
      .CLK_FRE(50),  //时钟频率，默认时钟频率为50MHz
      .DATA_WIDTH(DATA_WIDTH),  //有效数据位，缺省为8位
      .PARITY_ON(PARITY_ON),  //校验位，1为有校验位，0为无校验位，缺省为0
      .PARITY_TYPE(PARITY_TYPE),      //校验类型，1为奇校验，0为偶校验，缺省为偶校验
      .BAUD_RATE(BAUD_RATE)  //波特率，缺省为9600
  ) u_uart_rx (
      .i_clk_sys  (i_clk_sys),    //系统时钟
      .i_rst_n    (i_rst_n),      //全局异步复位,低电平有效
      .i_uart_rx  (i_uart_rx),    //UART输入
      .o_uart_data(w_data),       //UART接收数据
      .o_ld_parity(o_ld_parity),  //校验位检验LED，高电平位为校验正确
      .o_rx_done  (w_rx_done)     //UART数据接收完成标志
  );

  uart_tx #(
      .CLK_FRE(50),  //时钟频率，默认时钟频率为50MHz
      .DATA_WIDTH(DATA_WIDTH),  //有效数据位，缺省为8位
      .PARITY_ON(PARITY_ON),  //校验位，1为有校验位，0为无校验位，缺省为0
      .PARITY_TYPE(PARITY_TYPE),      //校验类型，1为奇校验，0为偶校验，缺省为偶校验
      .BAUD_RATE(BAUD_RATE)  //波特率，缺省为9600
  ) u_uart_tx (
      .i_clk_sys   (i_clk_sys),  //系统时钟
      .i_rst_n     (i_rst_n),    //全局异步复位
      .i_data_tx   (w_data),     //传输数据输入
      .i_data_valid(w_rx_done),  //传输数据有效
      .o_uart_tx   (o_uart_tx)   //UART输出
  );

endmodule
