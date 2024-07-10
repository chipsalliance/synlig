source ../yosys_common.tcl

hierarchy
procs
opt
async2sync
sat -verify -seq 1 -tempinduct -prove-asserts -show-all
