source ../yosys_common.tcl

hierarchy
procs
opt
sat -verify -seq 1 -tempinduct -prove-asserts -show-all
