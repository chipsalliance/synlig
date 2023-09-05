source ../yosys_common.tcl
prep -top \\top
write_verilog
write_verilog yosys.sv
sim -rstlen 10 -vcd dump.vcd
