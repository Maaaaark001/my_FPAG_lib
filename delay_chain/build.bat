echo "building..."
iverilog -g2012 -o sim.out tb_delay_chain.sv delay_chain.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
