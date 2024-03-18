echo "building..."
iverilog -g2012 -o sim.out tb_encoder.sv encoder.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
