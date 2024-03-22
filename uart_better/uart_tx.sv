module uart_tx #(
    parameter CLK_FRE = 50,  //时钟频率，默认时钟频率为50MHz
    parameter DATA_WIDTH = 8,  //有效数据位，缺省为8位
    parameter PARITY_ON = 0,  //校验位，1为有校验位，0为无校验位，缺省为0
    parameter PARITY_TYPE = 0,  //校验类型，1为奇校验，0为偶校验，缺省为偶校验
    parameter BAUD_RATE = 9600  //波特率，缺省为9600
) (
    input                         i_clk_sys,     //系统时钟
    input                         i_rst_n,       //全局异步复位
    input      [DATA_WIDTH-1 : 0] i_data_tx,     //传输数据输入
    input                         i_data_valid,  //传输数据有效
    output reg                    o_uart_tx      //UART输出
);


  //状态机定义
  reg [2:0] r_current_state;  //当前状态
  reg [2:0] r_next_state;  //次态

  localparam STATE_IDLE = 3'b000;  //空闲状态
  localparam STATE_START = 3'b001;  //开始状态
  localparam STATE_DATA = 3'b011;  //数据发送状态
  localparam STATE_PARITY = 3'b100;  //数据校验计算和发送
  localparam STATE_END = 3'b101;  //结束状态


  localparam CYCLE = CLK_FRE * 1000000 / BAUD_RATE;  //波特计数周期

  reg        baud_valid;  //波特计数有效位
  reg [15:0] baud_cnt;  //波特率计数器
  reg        baud_pulse;  //波特率采样脉冲

  reg [ 3:0] r_tx_cnt;  //接收数据位计数

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
      if (r_tx_cnt == DATA_WIDTH) begin
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


  reg [DATA_WIDTH-1 : 0] r_data_tx;
  reg                    r_parity_check;
  //状态机输出逻辑
  always @(posedge i_clk_sys or negedge i_rst_n) begin
    if (!i_rst_n) begin
      baud_valid  <= 1'b0;
      r_data_tx   <= 'd0;
      o_uart_tx   <= 1'b1;
      r_tx_cnt    <= 4'd0;
      r_parity_check <= 1'b0;
    end else
      case (r_current_state)
        STATE_IDLE: begin
          o_uart_tx   <= 1'b1;
          r_tx_cnt    <= 4'd0;
          r_parity_check <= 4'd0;
          if (i_data_valid) begin
            baud_valid <= 1'b1;
            r_data_tx  <= i_data_tx;
          end
        end
        STATE_START: begin
          if (baud_pulse) o_uart_tx <= 1'b0;
        end
        STATE_DATA: begin
          if (baud_pulse) begin
            r_tx_cnt <= r_tx_cnt + 1'b1;
            o_uart_tx <= r_data_tx[0];
            r_parity_check <= r_parity_check + r_data_tx[0];
            r_data_tx <= {1'b0, r_data_tx[DATA_WIDTH-1:1]};
          end
        end
        STATE_PARITY: begin
          if (baud_pulse) begin
            if (PARITY_TYPE == 1) o_uart_tx <= r_parity_check;
            else o_uart_tx <= r_parity_check + 1'b1;
          end
        end
        STATE_END: begin
          if (baud_pulse) begin
            o_uart_tx  <= 1'b1;
            baud_valid <= 1'b0;
          end
        end
        default: ;
      endcase
  end

endmodule
