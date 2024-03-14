echo "building..."
iverilog -g2012 -o sim.out tb_key_process.sv key_process.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
