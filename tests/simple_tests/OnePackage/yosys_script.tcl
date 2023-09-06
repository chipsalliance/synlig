source ../yosys_common.tcl

prep -top \\dut
write_verilog
write_verilog yosys.sv
