source ../yosys_common.tcl

prep -top \\top
write_verilog
write_verilog yosys.sv
async2sync
sim -rstlen 10 -vcd dump.vcd
