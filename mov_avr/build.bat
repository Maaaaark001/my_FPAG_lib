echo "building..."
iverilog -g2012 -o sim.out tb_mov_avr.sv mov_avr.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
