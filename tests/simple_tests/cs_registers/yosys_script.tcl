source ../yosys_common.tcl

prep -top \\dut
write_verilog
write_verilog yosys.sv
sat -verify -seq 100 -tempinduct -prove-asserts -show-all
