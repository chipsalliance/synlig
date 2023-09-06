source ../yosys_common.tcl

hierarchy -check
procs
opt -full -purge -share_all
techmap
abc
clean
write_verilog -noattr
