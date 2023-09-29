yosys plugin -i systemverilog
yosys -import

if {$::env(PARSER) == "surelog" } {
	puts "Using Yosys read_uhdm command"
	read_uhdm -debug $::env(TOP_MODULE).uhdm
} elseif {$::env(PARSER) == "yosys-plugin" } {
	puts "Using Yosys read_systemverilog command"
	if { [info exists ::env(SURELOG_FLAGS)] } {
 		eval read_systemverilog -debug -no_dump_ptr -defer $::env(SURELOG_FLAGS) $::env(TEST_DIR)/separate_compilation_pkg.sv
        eval read_systemverilog -debug -no_dump_ptr -defer $::env(SURELOG_FLAGS) $::env(TEST_DIR)/separate_compilation_buf.sv
        eval read_systemverilog -debug -no_dump_ptr -defer $::env(SURELOG_FLAGS) $::env(TEST_DIR)/separate_compilation.v
	} else {
		eval read_systemverilog -debug -no_dump_ptr -defer $::env(TEST_DIR)/separate_compilation_pkg.sv
        eval read_systemverilog -debug -no_dump_ptr -defer $::env(TEST_DIR)/separate_compilation_buf.sv
        eval read_systemverilog -debug -no_dump_ptr -defer $::env(TEST_DIR)/separate_compilation.v
	}
} elseif {$::env(PARSER) == "yosys" } {
	puts "Using Yosys read_verilog command"
	read_verilog -sv -debug $::env(TEST_DIR)/separate_compilation_pkg.sv
	read_verilog -sv -debug $::env(TEST_DIR)/separate_compilation_buf.sv
	read_verilog -sv -debug $::env(TEST_DIR)/separate_compilation.v
} else {
	error "Invalid PARSER"
}

read_systemverilog -link
hierarchy
write_verilog
