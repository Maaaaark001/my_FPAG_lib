echo "building..."
iverilog -g2012 -o sim.out frequency_conter_test.sv frequency_conter.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
