`include "defines.sv"

module SPI_MASTER(
    input   wire                        clk     ,
    input   wire                        rst_n   ,
    input   wire                        miso    ,
    input   wire    [`DATA_WIDTH-1:0]   data_i  ,
    input   wire                        start   ,

    output  wire                        mosi    ,
    output  reg                         sclk    ,
    output  reg                         ss_n    ,
    output  wire                        finish
);
    parameter       IDLE    =   5'b00001  ,
                    //CHOOSE  =   5'b00010  ,
                    DATA    =   5'b00100  ,
                    EXTRA   =   5'b01000  ,
                    FINISH  =   5'b10000  ;

    parameter       CNT_MAX =   `CLK_FREQ / `SCLK_FREQ - 1;

    reg     [31:0]      cnt                     ;   //sclk的时钟周期的计数器
    reg     [4:0]       state                   ;
    reg     [4:0]       nx_state                ;
    wire    [3:0]       cnt_data                ;   //输出的数据计数器
    reg                 sclk_dly                ;   //sclk的打一拍信号
    reg     [3:0]       cnt_sclk_pos            ;   //sclk的上升沿计数器信号
    reg     [3:0]       cnt_sclk_neg            ;   //sclk的下降沿计数器信号
    reg                 start_dly               ;   //start的打一拍信号
    reg     [3:0]       cnt_data_dly            ;

    wire                cnt_max_flag            ;   //计数器cnt达到最大值的信号
    wire                dec_pos_or_neg_sample   ;   //1 posedge sample, 0 negedge sample
    wire                sclk_posedge            ;   //sclk的上升沿
    wire                sclk_negedge            ;   //sclk的下降沿


    assign  dec_pos_or_neg_sample = (`CPOL == `CPHA) ? 1'b1 : 1'b0;

    assign cnt_max_flag = (cnt == CNT_MAX ) ? 1'b1 : 1'b0;
    assign sclk_posedge = ((sclk == 1'b1) && (sclk_dly == 1'b0)) ? 1'b1 : 1'b0;
    assign sclk_negedge = ((sclk == 1'b0) && (sclk_dly == 1'b1)) ? 1'b1 : 1'b0;
    assign cnt_data = dec_pos_or_neg_sample ? cnt_sclk_pos : cnt_sclk_neg;

    always @(posedge clk or negedge rst_n) begin
        sclk_dly <= sclk;
        start_dly <= start;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt_sclk_pos <= 4'd0;
        end
        else if(state == FINISH) begin
            cnt_sclk_pos <= 4'd0;
        end
        //else if((sclk_posedge) && (cnt_sclk_pos == `DATA_WIDTH - 1)) begin
        //    cnt_sclk_pos <= `DATA_WIDTH - 1;
        //end
        else if(sclk_posedge) begin
            cnt_sclk_pos <= cnt_sclk_pos + 1'b1;
        end
        else begin
            cnt_sclk_pos <= cnt_sclk_pos;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt_sclk_neg <= 4'd0;
        end
        else if(state == FINISH) begin
            cnt_sclk_neg <= 4'd0;
        end
        //else if((sclk_negedge) && (cnt_sclk_neg == `DATA_WIDTH - 1)) begin
        //    cnt_sclk_neg <= `DATA_WIDTH - 1;
        //end
        else if(sclk_negedge) begin
            cnt_sclk_neg <= cnt_sclk_neg + 1'b1;
        end
        else begin
            cnt_sclk_neg <= cnt_sclk_neg;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end
        else begin
            state <= nx_state;
        end
    end

    always @(*) begin
        nx_state <= IDLE;
        case(state)
            IDLE:   nx_state <= start_dly ? DATA : IDLE;
            DATA:   nx_state <= (cnt_data == `DATA_WIDTH) ? (`CPHA == 0) ? EXTRA : FINISH : DATA;
            EXTRA:  nx_state <= cnt_max_flag ? FINISH : EXTRA ;
            FINISH: nx_state <= IDLE;
            default:nx_state <= IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt <= 'd0;
        end
        else if((state == DATA) && (nx_state == FINISH) && (cnt == CNT_MAX)) begin
            cnt <= 'd0;
        end
        else if((state == DATA) && (nx_state == EXTRA) && (cnt == CNT_MAX)) begin
            cnt <= 'd0;
        end
        else if((state == DATA) && (cnt == CNT_MAX)) begin
            cnt <= 'd0;
        end
        else if((state == EXTRA) && (cnt == CNT_MAX)) begin
            cnt <= 'd0;
        end
        else if(state == DATA) begin
            cnt <= cnt + 1'b1;
        end
        else if(state == EXTRA) begin
            cnt <= cnt + 1'b1;
        end
        else begin
            cnt <= 'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sclk <= (`CPOL) ? 1'b1 : 1'b0;
        end
        else if(start_dly) begin
            sclk <= ~sclk;
        end
        else if((state == DATA) && (cnt_max_flag) && (cnt_data < `DATA_WIDTH) ) begin
            sclk <= ~sclk;
        end
        else if((state == DATA) && (cnt_max_flag) && (cnt_data == `DATA_WIDTH) && (nx_state == EXTRA)) begin
            sclk <= ~sclk;
        end
        else if((state == EXTRA) && (cnt_max_flag) && (nx_state == FINISH)) begin
            sclk <= ~sclk;
        end
        else begin
            sclk <= sclk;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ss_n <= 1'b1;
        end
        else if(start) begin
            ss_n <= 1'b0;
        end
        else if(state == FINISH) begin
            ss_n <= 1'b1;
        end
        else begin
            ss_n <= ss_n;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt_data_dly <= 'd0;
        end
        else begin
            cnt_data_dly <= cnt_data;
        end
    end

    assign finish = (state == FINISH) ? 1'b1 : 1'b0;

    assign mosi  = (state == DATA) ? ((cnt_data_dly < `DATA_WIDTH) ? data_i[cnt_data_dly] : data_i[`DATA_WIDTH-1]) : data_i[0];
endmodule

module SPI_SLAVE(
    input   wire                        clk         ,
    input   wire                        rst_n       ,
    input   wire                        mosi        ,
    input   wire                        sclk        ,
    input   wire                        tx_finish   ,
    input   wire                        start       ,
    input   wire                        ss_n        ,

    output  wire    [`DATA_WIDTH-1:0]   data_o      ,
    //output  wire                        miso        ,
    output  wire                        r_finish
);
    parameter       IDLE    =   4'b0001     ,
                    RV_DATA =   4'b0010     ,
                    FINISH  =   4'b0100     ;

    wire                        sclk_posedge        ;
    wire                        sclk_negedge        ;
    wire                        dec_pos_or_neg_sample;
    //wire                        sclk_posedge        ;
    //wire                        sclk_negedge        ;


    reg                         sclk_dly            ;
    reg     [`DATA_WIDTH-1:0]   data_shift_pos      ;
    reg     [`DATA_WIDTH-1:0]   data_shift_neg      ;
    reg     [3:0]               state               ;
    reg     [3:0]               nx_state            ;
    reg     [3:0]               cnt_sclk_pos        ;
    reg     [3:0]               cnt_sclk_neg        ;
    wire    [3:0]               num_sample_data     ;

    assign  sclk_posedge = ((sclk == 1'b1) && (sclk_dly == 1'b0)) ? 1'b1 : 1'b0;
    assign  sclk_negedge = ((sclk == 1'b0) && (sclk_dly == 1'b1)) ? 1'b1 : 1'b0;
    assign  dec_pos_or_neg_sample = (`CPOL == `CPHA) ? 1'b1 : 1'b0;
    //assign  sclk_posedge = ((sclk == 1'b1) && (sclk_dly == 1'b0)) ? 1'b1 : 1'b0;
    //assign  sclk_negedge = ((sclk == 1'b0) && (sclk_dly == 1'b1)) ? 1'b1 : 1'b0;
    assign  num_sample_data = (dec_pos_or_neg_sample) ? cnt_sclk_pos : cnt_sclk_neg;

    always @(posedge clk or negedge rst_n) begin
        sclk_dly <= sclk;
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end
        else begin
            state <= nx_state;
        end
    end

    always @(*) begin
        nx_state <= IDLE;
        case(state)
            IDLE: nx_state <= start ? RV_DATA :IDLE;
            RV_DATA: begin
                if((num_sample_data == 7) && (dec_pos_or_neg_sample) && (sclk_posedge) && (!ss_n)) begin
                    nx_state <= FINISH;
                end
                else if((num_sample_data == 7) && (~dec_pos_or_neg_sample) && (sclk_negedge) && (!ss_n)) begin
                    nx_state <= FINISH;
                end
                else begin
                    nx_state <= RV_DATA;
                end
            end
            FINISH: nx_state <= IDLE;
        endcase
    end


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt_sclk_pos <= 4'd0;
        end
        else if((state == FINISH)) begin
            cnt_sclk_pos <= 4'd0;
        end
        else if(sclk_posedge) begin
            cnt_sclk_pos <= cnt_sclk_pos + 1'b1;
        end
        else begin
            cnt_sclk_pos <= cnt_sclk_pos;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt_sclk_neg <= 4'd0;
        end
        else if (state == FINISH) begin
            cnt_sclk_neg <= 4'd0;
        end
        else if (sclk_negedge) begin
            cnt_sclk_neg <= cnt_sclk_neg + 1'b1;
        end
        else begin
            cnt_sclk_neg <= cnt_sclk_neg;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_shift_pos <= {`DATA_WIDTH{1'b0}};
        end
        else if((state == RV_DATA) && (sclk_posedge)) begin
            data_shift_pos <= {mosi, data_shift_pos[`DATA_WIDTH-1:1]};
        end
        else if (state == FINISH) begin
            data_shift_pos <= {`DATA_WIDTH{1'b0}};
        end
        else begin
            data_shift_pos <= data_shift_pos;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_shift_neg <= {`DATA_WIDTH{1'b0}};
        end
        else if((state == RV_DATA) && (sclk_negedge)) begin
            data_shift_neg <= {mosi, data_shift_neg[`DATA_WIDTH-1:1]};
        end
        else if(state == FINISH) begin
            data_shift_neg <= {`DATA_WIDTH{1'b0}};
        end
        else begin
            data_shift_neg <= data_shift_neg;
        end
    end

    //assign data_o = dec_pos_or_neg_sample ? data_shift_pos : data_shift_neg;

    assign  data_o = (state == FINISH) ? (dec_pos_or_neg_sample ? data_shift_pos : data_shift_neg): {`DATA_WIDTH{1'b0}};
    assign  r_finish = (state == FINISH);




endmodule
