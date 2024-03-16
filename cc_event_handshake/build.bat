echo "building..."
iverilog -g2012 -o sim.out tb_cc_event_handshake.sv cc_event_handshake.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
