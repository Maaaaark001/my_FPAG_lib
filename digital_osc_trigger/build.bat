echo "building..."
iverilog -g2012 -o sim.out tb_digital_osc_trigger.sv digital_osc_trigger.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
