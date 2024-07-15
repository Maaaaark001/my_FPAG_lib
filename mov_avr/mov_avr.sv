// This module is a simple moving average filter with a configurable number of stages.

module MovAvr #(
    parameter WIDTH   = 1024,
    parameter DIV_BIT = 16,
    parameter ADD_DW  = 32
) (
    input sys_clk,
    input sys_rst_n,
    input clk_en,
    input signed [15:0] indata,
    output logic signed [15:0] AVR,
    output logic signed [15:0] AC_data

    // output logic signed[15:0]data_buf[0:WIDTH-1],
    // output  logic signed[ADD_DW-1:0]add_buf1

);
  logic signed [15:0] data_buf[0:WIDTH-1];
  logic signed [ADD_DW-1:0] add_buf1 = 0;
  //    initial begin
  //     add_buf1<=0;
  //    end
  logic signed [15:0] add_buf2 = 0;
  always_ff @(posedge sys_clk) begin
    if (!sys_rst_n) begin
      for (int i = 0; i < WIDTH; i = i + 1) begin
        data_buf[i] <= 0;
      end
    end else begin
      if (clk_en) begin
        for (int i = WIDTH - 2; i >= 0; i = i - 1) begin
          data_buf[i+1] <= data_buf[i];
        end
        data_buf[0] <= indata;
      end
    end
  end
  always_ff @(posedge sys_clk) begin
    if (!sys_rst_n) begin
      add_buf2 <= 0;
      add_buf1 <= 0;
    end else begin
      if (clk_en) begin
        add_buf1 <= add_buf1 - data_buf[WIDTH-1] + indata;
        add_buf2 <= add_buf1[ADD_DW-1:DIV_BIT];
        AVR <= add_buf2;
        AC_data <= indata - AVR;
      end
    end
  end
endmodule


module MovAvrRMS #(
    parameter WIDTH   = 1024,
    parameter DIV_BIT = 16,
    parameter ADD_DW  = 32
) (
    input sys_clk,
    input sys_rst_n,
    input clk_en,
    input signed [15:0] indata,
    output logic signed [15:0] AVR,
    output logic signed [15:0] AC_data

    // output logic signed[15:0]data_buf[0:WIDTH-1],
    // output  logic signed[ADD_DW-1:0]add_buf1

);
  logic signed [15:0] data_buf[0:WIDTH-1];
  logic signed [ADD_DW-1:0] add_buf1 = 0;
  //    initial begin
  //     add_buf1<=0;
  //    end
  logic signed [15:0] add_buf2 = 0;
  always_ff @(posedge sys_clk) begin
    if (!sys_rst_n) begin
      for (int i = 0; i < WIDTH; i = i + 1) begin
        data_buf[i] <= 0;
      end
    end else begin
      if (clk_en) begin
        for (int i = WIDTH - 2; i >= 0; i = i - 1) begin
          data_buf[i+1] <= data_buf[i];
        end
        data_buf[0] <= indata;
      end
    end
  end
  always_ff @(posedge sys_clk) begin
    if (!sys_rst_n) begin
      add_buf2 <= 0;
      add_buf1 <= 0;
    end else begin
      if (clk_en) begin
        add_buf1 <= add_buf1 - data_buf[WIDTH-1] + indata;
        add_buf2 <= add_buf1[ADD_DW-1:DIV_BIT];
        AVR <= add_buf2;
        AC_data <= indata - AVR;
      end
    end
  end
endmodule
