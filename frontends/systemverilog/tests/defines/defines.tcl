yosys -import
if { [info procs read_uhdm] == {} } { plugin -i systemverilog }
yosys -import  ;# ingest plugin commands

set TMP_DIR $::env(TEST_OUTPUT_PREFIX)/tmp
file mkdir $TMP_DIR

systemverilog_defines -DPONA
systemverilog_defines -DPAKALA
systemverilog_defines -UPAKALA
read_systemverilog -o $TMP_DIR $::env(DESIGN_TOP).v
hierarchy
write_verilog
