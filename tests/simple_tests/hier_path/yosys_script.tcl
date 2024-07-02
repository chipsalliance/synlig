source ../yosys_common.tcl

prep -top \\dut
hierarchy; procs; opt
write_verilog
write_verilog yosys.sv
select -module dut
async2sync
sat -verify -seq 1 -tempinduct -prove-asserts -show-all
