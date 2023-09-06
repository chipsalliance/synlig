source ../yosys_common.tcl

prep -top \\top
write_verilog
write_verilog yosys.sv
sim -clock i -rstlen 10 -vcd dump.vcd
