yosys -import
if { [info procs read_uhdm] == {} } { plugin -i systemverilog }
yosys -import  ;# ingest plugin commands

set TMP_DIR $::env(TEST_OUTPUT_PREFIX)/tmp
file mkdir $TMP_DIR

# Testing simple round-trip
read_systemverilog -o $TMP_DIR $::env(DESIGN_TOP).v
prep
write_table [test_output_path $::env(DESIGN_TOP).out]
