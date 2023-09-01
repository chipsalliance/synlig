yosys -import
if { [info procs read_uhdm] == {} } { plugin -i systemverilog }
yosys -import  ;# ingest plugin commands

set TMP_DIR $::env(TEST_OUTPUT_PREFIX)/tmp
file mkdir $TMP_DIR

# Define forbidden value
systemverilog_defaults -add -DPAKALA
# Stash it
systemverilog_defaults -push
systemverilog_defaults -clear
read_systemverilog -o $TMP_DIR $::env(DESIGN_TOP).v
# Allow parsing the module again
delete top
systemverilog_defaults -pop
# Skip check for forbidden value
systemverilog_defaults -add -Pbypass=1
read_systemverilog -o $TMP_DIR $::env(DESIGN_TOP).v
hierarchy
write_verilog
