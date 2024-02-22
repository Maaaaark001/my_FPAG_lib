echo "building..."
iverilog -g2012 -o sim.out tb_pulse_widen.sv pulse_widen.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
