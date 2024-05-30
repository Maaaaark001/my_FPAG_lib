//等精度测量法(低频)
module frequency_conter (
        input                 clk_fs ,
        input                 rst_n  ,
        input                 clk_fx ,

        output   reg [63:0]   fre
);

parameter	CLK_FS    = 26'd50_000_000;
parameter   GATE_TIME = 16'd100;    		//门控时间，越大误差越小，但测量时间也会变长

//reg define
reg                	gate_fx		;   		//门控信号，被测信号域下
reg                	gate_fs     ;           //同步到基准时钟的门控信号
reg                	gate_fs_r   ;          	//用于同步gate信号的寄存器
reg                	gate_fs_d0  ;           //用于采集基准时钟下gate下降沿
reg                	gate_fs_d1  ;           //用于采集基准时钟下gate下降沿
reg                	gate_fx_d0  ;          	//用于采集被测时钟下gate下降沿
reg                	gate_fx_d1  ;           //用于采集被测时钟下gate下降沿
reg    [15:0]   	gate_cnt    ;          	//门控计数
reg    [31:0]   	fs_cnt      ;           //门控时间内基准时钟的计数值
reg    [31:0]   	fs_cnt_temp ;           //fs_cnt 临时值
reg    [31:0]   	fx_cnt      ;           //门控时间内被测时钟的计数值
reg    [31:0]   	fx_cnt_temp ;           //fx_cnt 临时值

//wire define
wire               neg_gate_fs;            	//基准时钟下门控信号下降沿=
wire               neg_gate_fx;            	//被测时钟下门控信号下降沿

//捕捉信号下降沿
assign neg_gate_fs = gate_fs_d1 & (~gate_fs_d0);
assign neg_gate_fx = gate_fx_d1 & (~gate_fx_d0);

//检测gate_fx下降沿
always @(posedge clk_fx or negedge rst_n) begin
    if(!rst_n) begin
        gate_fx_d0 <= 1'b0;
        gate_fx_d1 <= 1'b0;
    end
    else begin
        gate_fx_d0 <= gate_fx;
        gate_fx_d1 <= gate_fx_d0;
    end
end
//检测gate_fs下降沿
always @(posedge clk_fs or negedge rst_n) begin
    if(!rst_n) begin
        gate_fs_d0 <= 1'b0;
        gate_fs_d1 <= 1'b0;
    end
    else begin
        gate_fs_d0 <= gate_fs;
        gate_fs_d1 <= gate_fs_d0;
    end
end
//被测时钟闸门计数器
always @(posedge clk_fx or negedge rst_n) begin
    if(!rst_n)
        gate_cnt <= 16'd0;
    else if(gate_cnt == GATE_TIME*2)
        gate_cnt <= 16'd0;
    else
        gate_cnt <= gate_cnt + 1'b1;
end
//被测时钟闸门生成
always @(posedge clk_fx or negedge rst_n) begin
    if(!rst_n)
        gate_fx <= 1'b0;
    else if(gate_cnt == GATE_TIME)
        gate_fx <= 1'b1;
    else if(gate_cnt == GATE_TIME*2)
        gate_fx <= 1'b0;
    else
        gate_fx <= gate_fx;
end
//把闸门从被测时钟域同步到基准时钟域
always @(posedge clk_fs or negedge rst_n) begin
    if(!rst_n) begin
        gate_fs_r <= 1'b0;
        gate_fs   <= 1'b0;
    end
    else begin
        gate_fs_r <= gate_fx;
        gate_fs   <= gate_fs_r;
    end
end
//在被测时钟域对被测信号计数
always @(posedge clk_fx or negedge rst_n) begin
    if(!rst_n) begin
        fx_cnt_temp <= 0;
        fx_cnt <= 0;
    end
    else if(gate_fx)
        fx_cnt_temp <= fx_cnt_temp + 1'b1;
    else if(neg_gate_fx) begin
        fx_cnt_temp <= 0;
        fx_cnt <= fx_cnt_temp;
    end
end
//在基准时钟域对基准时钟计数
always @(posedge clk_fs or negedge rst_n) begin
    if(!rst_n) begin
        fs_cnt_temp <= 0;
        fs_cnt <= 0;
    end
    else if(gate_fs)
        fs_cnt_temp <= fs_cnt_temp + 1'b1;
    else if(neg_gate_fs) begin
        fs_cnt_temp <= 0;
        fs_cnt <= fs_cnt_temp;
    end
end
//在基准时钟域输出结果
always @(posedge clk_fs or negedge rst_n) begin
    if(!rst_n) begin
        fre <= 0;
    end
    else if(gate_fs == 1'b0)
        fre <= (CLK_FS * fx_cnt ) / fs_cnt;
end
endmodule
