source ../yosys_common.tcl

prep -top \\dut
write_verilog
write_verilog yosys.sv
async2sync
sat -verify -seq 100 -tempinduct -prove-asserts -show-all
