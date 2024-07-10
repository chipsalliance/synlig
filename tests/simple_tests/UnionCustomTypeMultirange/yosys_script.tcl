source ../yosys_common.tcl

write_verilog -noattr
hierarchy
procs
opt
async2sync
sat -verify -seq 1 -tempinduct -prove-asserts -show-all
