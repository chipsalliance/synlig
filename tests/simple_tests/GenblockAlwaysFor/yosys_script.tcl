source ../yosys_common.tcl

proc_clean
proc_rmdead
proc_prune
proc_init
proc_arst
proc_mux
proc_dff
proc_clean
proc_dlatch
opt
sim -rstlen 10 -vcd dump.vcd
