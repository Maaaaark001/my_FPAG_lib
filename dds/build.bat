echo "building..."
iverilog -g2012 -o sim.out tb_dds.sv dds.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
