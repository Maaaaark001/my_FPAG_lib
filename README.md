### Intro.
- This repo is a simple System Verilog lib, most of them are forked from my teacher's book :[FPGA-Application-Development-and-Simulation](https://github.com/loykylewong/FPGA-Application-Development-and-Simulation)
- It is very easy to use it! I designed build.bat for windows, so before you use it you need to make sure that the Icarus Verilog program is included in the PATH, and then in each module folder you just need to type `.\build.bat` in the terminal or command line to automate the simulation flow and open gtkwave to observe the waveforms.
### Directory Structure.
##### The directory structure of the module is the same as below:
```
my_FPGA_lib
│  README.md
├─MODULE_NAME
│      MODULE_NAME.sv
│      tb_MODULE_NAME.sv
│      tb_MODULE_NAME2.sv
│      build.bat
│      sim.out
│      wave.vcd
```
- the MODULE_NAME.sv is the module itself.
- the tb_MODULE_NAME.sv is the testbench of this module.
- the tb_MODULE_NAME2.sv is also a testbench, in order to verify some other functions of the module
- the build.bat is a script written for simulation verification.
- the sim.out is the simulation file generated for the simulation process.
- the wavd.vcd is the waveform files.

### How to use it
- Before you use it you need to make sure that the Icarus Verilog program is included in the PATH
- Then in each module folder you just need to type `.\build.bat` in the terminal or command line to automate the simulation flow and open gtkwave to observe the waveforms.
