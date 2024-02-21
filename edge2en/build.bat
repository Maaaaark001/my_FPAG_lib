echo "building..."
iverilog -g2012 -o sim.out tb_edge2en.sv edge2en.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
