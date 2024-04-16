echo "building..."
iverilog -g2012 -o sim.out tb_pid.sv pid.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
