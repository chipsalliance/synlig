yosys -import
if { [info procs read_uhdm] == {} } { plugin -i systemverilog }
yosys -import  ;# ingest plugin commands

set TMP_DIR $::env(TEST_OUTPUT_PREFIX)/tmp
file mkdir $TMP_DIR

# Testing simple round-trip
read_systemverilog -odir $TMP_DIR -defer $::env(DESIGN_TOP)-pkg.sv
read_systemverilog -odir $TMP_DIR -defer $::env(DESIGN_TOP)-buf.sv
read_systemverilog -odir $TMP_DIR -defer $::env(DESIGN_TOP).v
read_systemverilog -odir $TMP_DIR -link
hierarchy
write_verilog
