echo "building..."
iverilog -g2012 -o sim.out tb_cordic.v
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
