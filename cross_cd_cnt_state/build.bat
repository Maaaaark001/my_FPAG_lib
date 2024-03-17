echo "building..."
iverilog -g2012 -o sim.out tb_cross_cd_cnt_state.sv cross_cd_cnt_state.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
