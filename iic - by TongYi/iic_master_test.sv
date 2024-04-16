`default_nettype none
`timescale 1ns/100ps

module i2c_master_tb;

// Inputs
reg clk;
reg reset;
reg start;
reg stop;
reg [7:0] address;
reg [7:0] data_in;

// Outputs
wire [7:0] data_out;
wire sda;
wire scl;

// Instantiate the Unit Under Test (UUT)
i2c_master uut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .stop(stop),
    .address(address),
    .data_in(data_in),
    .data_out(data_out),
    .sda(sda),
    .scl(scl)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10MHz clock
end

// Reset signal
initial begin
    reset = 1;
    #10 reset = 0;
end
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, i2c_master_tb );
    #1000000 $finish;
    end
// Test sequence
initial begin
    // Test write to device with address 01010101 (85 in decimal)
    address = 8'h55;
    data_in = 8'hAA;
    start = 1;
    #200 start = 0;

    // Test read from device with address 01010101 (85 in decimal)
    address = 8'h55;
    data_in = 8'h00; // Not used for reading
    start = 1;
    #200 start = 0;
    stop = 1;
    #200 stop = 0;

end
endmodule
