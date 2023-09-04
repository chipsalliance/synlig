source ../yosys_common.tcl

procs
write_verilog
write_verilog yosys.sv
select -assert-count 1 \\dut/gen_modules\[1\].module_in_genscope
select -assert-count 1 \\dut/gen_modules\[0\].module_in_genscope
