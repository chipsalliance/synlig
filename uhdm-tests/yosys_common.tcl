yosys plugin -i systemverilog
yosys -import

if {$::env(PARSER) == "surelog" } {
	puts "Using Yosys read_uhdm command"
	read_uhdm -debug $::env(TOP_MODULE).uhdm
} elseif {$::env(PARSER) == "yosys-plugin" } {
	puts "Using Yosys read_systemverilog command"
	if { [info exists ::env(SURELOG_FLAGS)] } {
		eval read_systemverilog -debug -no_dump_ptr $::env(SURELOG_FLAGS) $::env(TOP_FILE)
	} else {
		eval read_systemverilog -debug -no_dump_ptr $::env(TOP_FILE)
	}
} elseif {$::env(PARSER) == "yosys" } {
	puts "Using Yosys read_verilog command"
	read_verilog -sv -debug $::env(TOP_FILE)
} else {
	error "Invalid PARSER"
}
