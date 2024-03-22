module uart_rx #(
    parameter CLK_FRE = 50,  //时钟频率，默认时钟频率为50MHz
    parameter DATA_WIDTH = 8,  //有效数据位，缺省为8位
    parameter PARITY_ON = 0,  //校验位，1为有校验位，0为无校验位，缺省为0
    parameter PARITY_TYPE = 0,  //校验类型，1为奇校验，0为偶校验，缺省为偶校验
    parameter BAUD_RATE = 9600  //波特率，缺省为9600
) (
    input                         i_clk_sys,    //系统时钟
    input                         i_rst_n,      //全局异步复位,低电平有效
    input                         i_uart_rx,    //UART输入
    output reg [DATA_WIDTH-1 : 0] o_uart_data,  //UART接收数据
    output reg                    o_ld_parity,  //校验位检验LED，高电平位为校验正确
    output reg                    o_rx_done     //UART数据接收完成标志
);

  /*
    UART输入是异步输入，最好是同步到FPGA内部的时钟域
    可以省略，但在异步电路中，保持时钟域同步是一个良好习惯
    */
  reg sync_uart_rx;
  always @(posedge i_clk_sys or negedge i_rst_n) begin
    if (!i_rst_n) sync_uart_rx <= 1'b1;
    else sync_uart_rx <= i_uart_rx;
  end

  /*
    连续采样五个接收路电平来判断rx是否有信号传来
    用五个采样信号来作为判断标准可以有效排除毛刺噪声带来的误判
    */
  reg [4:0] r_flag_rcv_start;
  wire w_rcv_start;
  always @(posedge i_clk_sys or negedge i_rst_n) begin
    if (!i_rst_n) r_flag_rcv_start <= 5'b11111;
    else r_flag_rcv_start <= {r_flag_rcv_start[3:0], sync_uart_rx};
  end


  //状态机定义
  reg [2:0] r_current_state;  //当前状态
  reg [2:0] r_next_state;  //次态

  localparam STATE_IDLE = 3'b000;  //空闲状态
  localparam STATE_START = 3'b001;  //开始状态
  localparam STATE_DATA = 3'b011;  //数据接收状态
  localparam STATE_PARITY = 3'b100;  //数据校验状态
  localparam STATE_END = 3'b101;  //结束状态


  localparam CYCLE = CLK_FRE * 1000000 / BAUD_RATE;  //波特计数周期

  reg        baud_valid;  //波特计数有效位
  reg [15:0] baud_cnt;  //波特率计数器
  reg        baud_pulse;  //波特率采样脉冲

  reg [ 3:0] r_rcv_cnt;  //接收数据位计数

  //波特率计数器
  always @(posedge i_clk_sys or negedge i_rst_n) begin
    if (!i_rst_n) baud_cnt <= 16'h0000;
    else if (!baud_valid) baud_cnt <= 16'h0000;
    else if (baud_cnt == CYCLE - 1) baud_cnt <= 16'h0000;
    else baud_cnt <= baud_cnt + 1'b1;
  end

  //波特采样脉冲
  always @(posedge i_clk_sys or negedge i_rst_n) begin
    if (!i_rst_n) baud_pulse <= 1'b0;
    else if (baud_cnt == CYCLE / 2 - 1) baud_pulse <= 1'b1;
    else baud_pulse <= 1'b0;
  end

  //状态机状态变化定义
  always @(posedge i_clk_sys or negedge i_rst_n) begin
    if (!i_rst_n) r_current_state <= STATE_IDLE;
    else if (!baud_valid) r_current_state <= STATE_IDLE;
    else if (baud_valid && baud_cnt == 16'h0000) r_current_state <= r_next_state;
  end

  //状态机次态定义
  always @(*) begin
    case (r_current_state)
      STATE_IDLE:   r_next_state <= STATE_START;
      STATE_START:  r_next_state <= STATE_DATA;
      STATE_DATA:
      if (r_rcv_cnt == DATA_WIDTH) begin
        if (PARITY_ON == 0) r_next_state <= STATE_END;
        else r_next_state <= STATE_PARITY;  //校验位开启时进入校验状态
      end else begin
        r_next_state <= STATE_DATA;
      end
      STATE_PARITY: r_next_state <= STATE_END;
      STATE_END:    r_next_state <= STATE_IDLE;
      default:      ;
    endcase
  end


  reg [DATA_WIDTH - 1 : 0] r_data_rcv;
  reg r_parity_check;

  //状态机输出逻辑
  always @(posedge i_clk_sys or negedge i_rst_n) begin
    if (!i_rst_n) begin
      baud_valid <= 1'b0;
      r_data_rcv <= 'd0;
      r_rcv_cnt <= 4'd0;
      r_parity_check <= 1'b0;
      o_uart_data <= 'd0;
      o_ld_parity <= 1'b0;
      o_rx_done <= 1'b0;
    end else
      case (r_current_state)
        STATE_IDLE: begin
          //闲置状态下对寄存器进行复位
          r_rcv_cnt <= 4'd0;
          r_data_rcv <= 'd0;
          r_parity_check <= 1'b0;
          o_rx_done <= 1'b0;
          //连续检测到低电平时认为UART传来数据，拉高baud_valid
          if (r_flag_rcv_start == 5'b00000) baud_valid <= 1'b1;
        end
        STATE_START: begin
          if(baud_pulse && sync_uart_rx)     //波特率采样脉冲到来时再次检测是否为低电平，如果不为低电平，认为前期误检测，重新进入IDLE状态
            baud_valid <= 1'b0;
        end
        STATE_DATA: begin
          if (baud_pulse) begin
            r_data_rcv <= {sync_uart_rx, r_data_rcv[DATA_WIDTH-1 : 1]};  //数据移位存储
            r_rcv_cnt <= r_rcv_cnt + 1'b1;  //数据位计数
            r_parity_check <= r_parity_check + sync_uart_rx;        //校验位做加法验证高电平的奇偶
          end
        end
        STATE_PARITY: begin
          if (baud_pulse) begin
            //校验检测，正确则o_ld_parity拉高，可输出给led检测，如果闪烁则表示有错误数据发生
            if (r_parity_check + sync_uart_rx == PARITY_TYPE) o_ld_parity <= 1'b1;
            else o_ld_parity <= 1'b0;
          end else o_ld_parity <= o_ld_parity;
        end
        STATE_END: begin
          if (baud_pulse) begin
            //没有校验位或者校验位正确时才输出数据，否则直接丢弃数据
            if (PARITY_ON == 0 || o_ld_parity) begin
              o_uart_data <= r_data_rcv;
              o_rx_done   <= 1'b1;
            end
          end else begin
            o_rx_done <= 1'b0;
          end

          if (baud_cnt == 16'h0000) baud_valid <= 1'b0;
        end
        default: ;
      endcase
  end


endmodule
