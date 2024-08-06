source ../yosys_common.tcl

prep -top \\top
async2sync
sat -verify -seq 1 -tempinduct -prove-asserts -show-all
