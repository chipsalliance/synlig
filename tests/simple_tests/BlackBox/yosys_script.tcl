source ../yosys_common.tcl

prep -top \\dut
write_verilog
write_verilog yosys.sv
# The sim command does not work for designs with blackbox,
# it does not allow to add the blackboxes actual models back into the simulation 
# sim -clock clk -rstlen 10 -vcd dump.vcd
