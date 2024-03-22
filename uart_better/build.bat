echo "building..."
iverilog -g2012 -o sim.out tb_uart_loop.sv uart_loop.sv uart_tx.sv uart_rx.sv
echo "completed"
vvp sim.out
echo "open..."
gtkwave wave.vcd
