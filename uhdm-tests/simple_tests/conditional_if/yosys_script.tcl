source ../yosys_common.tcl

hierarchy -check -top \\top
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

opt_expr -keepdc
opt_clean
check
opt -noff -keepdc
wreduce -keepdc
opt_clean
memory_collect
opt -noff -keepdc -fast
stat
check

write_verilog yosys.sv
sim -rstlen 10 -vcd dump.vcd
