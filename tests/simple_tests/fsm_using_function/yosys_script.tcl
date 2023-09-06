source ../yosys_common.tcl

prep -top \\fsm_using_function
write_verilog
write_verilog yosys.sv
sim -clock clock -rstlen 10 -vcd dump.vcd
