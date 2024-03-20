`ifndef __SPI_SV__
`define __SPI_SV__
`include "../counter/counter.sv"
`include "../edge2en/edge2en.sv"
module SpiMaster #(
    parameter HBR_DIV = 5,    //10Msps@100MHz
    parameter CHPA = 0
)(
    input wire clk, rst, start,
    input wire [23:0] ss_mask,
    input wire [7:0] trans_len,
    output logic read,
    input wire [7:0] tx_data,
    output logic valid,
    output logic [7:0] rx_data,
    output logic busy,
    output logic sclk0, sclk1, mosi, mosi_tri,
    input wire miso,
    output logic [23:0] ss_n
);
    // hbr_cnt & hbit_cnt
    logic hbr_co, hbit_co;
    logic [12:0] hbit_cnt; // 2 + 16 * 256 = 4098 -> 13bit
    logic [12:0] hbit_cnt_max;
    always_ff@(posedge clk) begin
        if(rst) hbit_cnt_max <= '0;
        else if(start)
            hbit_cnt_max <= 13'd1 + ((13'(trans_len) + 13'd1) << 4);
    end
    Counter #(HBR_DIV) hbrCnt(clk, rst, busy, , hbr_co);
    CounterMax #(13) hbitCnt(
        clk, rst, hbr_co, hbit_cnt_max, hbit_cnt, hbit_co);
    // busy driven
    always_ff@(posedge clk) begin
        if(rst) busy <= '0;
        else if(start) busy <= '1;
        else if(hbit_co) busy <= '0;
    end
    // tx_data & mosi
    assign read = (CHPA == 0)?
                      start | (hbit_cnt[3:0] == 4'd15
                      & hbr_co & hbit_cnt < hbit_cnt_max - 13'd16)
                    : hbit_cnt[3:0] == 4'd0 & hbr_co
                      & hbit_cnt < hbit_cnt_max - 16;
    logic read_dly;
    always_ff@(posedge clk) read_dly <= read;
    wire out_shift = (CHPA == 0)? hbit_cnt[0] == 1'd1 & hbr_co
                                : hbit_cnt[0] == 1'd0 & hbr_co;
    logic [7:0] mosi_shift_reg;
    always_ff@(posedge clk) begin
        if(rst) mosi_shift_reg <= '0;
        else if(read_dly) mosi_shift_reg <= tx_data;
        else if(out_shift) mosi_shift_reg <= mosi_shift_reg >> 1;
    end
    assign mosi_tri = ~busy;
    always_ff@(posedge clk) mosi <= mosi_shift_reg[0];
    // miso & rx_data
    wire in_shift = (CHPA == 0)? hbit_cnt[0] == 1'd1 & hbr_co
                  : hbit_cnt[0] == 1'd0 & hbr_co;
    wire out_valid = (CHPA == 0)? hbit_cnt[3:0] == 4'd15 & hbr_co
                  : hbit_cnt[3:0] == 4'd0 & hbr_co & hbit_cnt > 0;
    always_ff@(posedge clk) valid <= out_valid;
    logic [7:0] miso_shift_reg;
    always_ff@(posedge clk) begin
        if(rst) miso_shift_reg <= '0;
        else if(in_shift)
            miso_shift_reg <= {miso, miso_shift_reg[7:1]};
    end
    always_ff@(posedge clk) begin
        if(rst) rx_data <= '0;
        else if(out_valid) rx_data <= {miso, miso_shift_reg[7:1]};
    end
    // sclk & ss
    logic [23:0] ss_mask_reg;
    always_ff@(posedge clk) begin
        if(rst) ss_mask_reg <= '0;
        else if(start) ss_mask_reg <= ss_mask;
    end
    always_ff@(posedge clk) begin
        if(rst) begin sclk0 <= '0; sclk1 <= '1; end
        else if(hbit_cnt < hbit_cnt_max) begin
            sclk0 <= hbit_cnt[0];
            sclk1 <= ~hbit_cnt[0];
        end
    end
    always_ff@(posedge clk) begin
        if(rst) ss_n <= '1;
        else if(busy && hbit_cnt < hbit_cnt_max)
            ss_n <= ~ss_mask_reg;
        else ss_n <= '1;
    end
endmodule

module SpiSlave #(
    parameter CHPA = 0
)(
    input wire clk, rst, ss_n,
    input wire sclk0, mosi,
    output logic miso, miso_tri,
    output logic read,
    input wire [7:0] tx_data,
    output logic valid,
    output logic [7:0] rx_data,
    output logic busy
);
    logic ss_n_reg; always_ff@(posedge clk) ss_n_reg <= ss_n;
    logic mosi_reg; always_ff@(posedge clk) mosi_reg <= mosi;
    // ss_n & sclk rising & falling
    logic sclk_r, sclk_f, ss_n_rising, ss_n_falling;
    wire sclk_rising = sclk_r & ~ss_n_reg;
    wire sclk_falling = sclk_f & ~ss_n_reg;
    Edge2En #(1)
        ssnEdgeDet(clk, ss_n, ss_n_rising, ss_n_falling, ),
        sclkEdgeDet(clk, sclk0, sclk_r, sclk_f, );
    // bit_cnt
    logic [11:0] bit_cnt;
    wire bit_cnt_en =
        ~ss_n_reg & ((CHPA == 0) ? sclk_rising : sclk_falling);
    Counter #(4096) bitCnt(
        clk, rst | ss_n_falling, bit_cnt_en, bit_cnt, );
    // busy driven
    always_ff@(posedge clk) begin
        if(rst) busy <= '0;
        else if(ss_n_falling) busy <= '1;
        else if(ss_n_rising) busy <= '0;
    end
    // tx_data & miso
    assign read = (CHPA == 0)?
                    ss_n_falling | (sclk_falling && bit_cnt[2:0] == 3'd0)
                  : sclk_rising && bit_cnt[2:0] == 3'd0;
    logic read_dly;
    always_ff@(posedge clk) read_dly <= read;
    wire out_shift = (CHPA == 0)? sclk_falling : sclk_rising;
    logic [7:0] miso_shift_reg;
    always_ff@(posedge clk) begin
        if(rst) miso_shift_reg <= '0;
        else if(read_dly) miso_shift_reg <= tx_data;
        else if(out_shift & ~read)
            miso_shift_reg <= miso_shift_reg >> 1;
    end
    assign miso = miso_shift_reg[0];
    assign miso_tri = ss_n_reg;
    // mosi & rx_data
    wire in_shift = (CHPA == 0)? sclk_rising : sclk_falling;
    wire out_valid = (CHPA == 0)? sclk_rising && bit_cnt[2:0] == 3'd7
                                 : sclk_falling && bit_cnt[2:0] == 3'd7;
    always_ff@(posedge clk) valid <= out_valid;
    logic [7:0] mosi_shift_reg;
    always_ff@(posedge clk) begin
        if(rst) mosi_shift_reg <= '0;
        else if(in_shift)
            mosi_shift_reg <= {mosi, mosi_shift_reg[7:1]};
    end
    always_ff@(posedge clk) begin
        if(rst) rx_data <= '0;
        else if(out_valid) rx_data <= {mosi, mosi_shift_reg[7:1]};
    end
endmodule

`endif
