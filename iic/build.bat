echo "building..."
iverilog -g2012 -o sim.out iic_master_slave_test.sv iic_master.sv iic_slave.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
