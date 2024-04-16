module i2c_master(
    input wire clk,
    input wire reset,
    input wire start,    // Start信号，高电平有效
    input wire stop,     // Stop信号，高电平有效
    input wire [7:0] address, // 7位设备地址加上R/W位
    input wire [7:0] data_in, // 数据输入
    output reg [7:0] data_out, // 数据输出
    output reg sda,    // SDA数据线
    output reg scl      // SCL时钟线
);

// 内部状态定义
localparam [2:0] IDLE = 3'b000, ADDR = 3'b001, WRITE = 3'b010, READ = 3'b011, STOP = 3'b100;
reg [2:0] state, next_state;

// 计数器，用于位控制
reg [3:0] bit_counter, next_bit_counter;

// 数据寄存器
reg [7:0] shift_reg, next_shift_reg;

// SCL和SDA信号的控制逻辑
always @(posedge clk or posedge reset) begin
    if (reset) begin
        sda <= 1'bZ;
        scl <= 1'bZ;
    end else begin
        case (state)
            IDLE: begin
                sda <= 1'bZ;
                scl <= 1'b1;
            end
            ADDR: begin
                sda <= address[0];
                scl <= 1'b1;
            end
            WRITE: begin
                sda <= shift_reg[0];
                scl <= 1'b1;
            end
            READ: begin
                sda <= 1'bZ;
                scl <= 1'b1;
            end
            STOP: begin
                sda <= 1'bZ;
                scl <= 1'b0;
            end
        endcase
    end
end

// 状态机逻辑
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

// 状态转换逻辑
always @(*) begin
    next_state = state;
    next_bit_counter = bit_counter;
    next_shift_reg = shift_reg;
    case (state)
        IDLE: begin
            if (start) begin
                next_state = ADDR;
                next_bit_counter = 1'b0;
                next_shift_reg = address;
            end
        end
        ADDR: begin
            if (bit_counter == 7) begin
                next_state = (address[7] == 1'b0) ? WRITE : READ;
                next_bit_counter = 0;
                next_shift_reg = data_in;
            end else begin
                next_bit_counter = bit_counter + 1'b1;
            end
        end
        WRITE: begin
            if (bit_counter == 7) begin
                next_state = STOP;
            end else begin
                bit_counter = bit_counter + 1'b1;
                shift_reg = {shift_reg[6:0], 1'b0}; // 移位并准备下一个数据位
            end
        end
        READ: begin
            if (bit_counter == 7) begin
                data_out = shift_reg;
                next_state = STOP;
            end else begin
                bit_counter = bit_counter + 1'b1;
                shift_reg = {1'b0, shift_reg[7:1]}; // 移位并准备存储下一个数据位
            end
        end
        STOP: begin
            next_state = IDLE;
        end
    endcase
end

endmodule
