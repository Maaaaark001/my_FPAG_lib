echo "building..."
iverilog -g2012 -o sim.out tb_scfifo.sv scfifo.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
