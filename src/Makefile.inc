
# Targets and dependencies from */*/Makefile.inc

# passes/pmgen/Makefile.inc
$(BUILD_DIR)%_pm.h: passes/pmgen/pmgen.py %.pmg
	$(P) mkdir -p $(dir $@) && $(PYTHON_EXECUTABLE) $< -o $@ -p $(subst _pm.h,,$(notdir $@)) $(filter-out $<,$^)

$(BUILD_DIR)/passes/pmgen/test_pmgen.o: passes/pmgen/test_pmgen_pm.h passes/pmgen/ice40_dsp_pm.h passes/pmgen/peepopt_pm.h passes/pmgen/xilinx_srl_pm.h
$(BUILD_DIR)/passes/pmgen/ice40_dsp.o: passes/pmgen/ice40_dsp_pm.h
$(BUILD_DIR)/passes/pmgen/ice40_wrapcarry.o: passes/pmgen/ice40_wrapcarry_pm.h
$(BUILD_DIR)/passes/pmgen/xilinx_dsp.o: passes/pmgen/xilinx_dsp_pm.h passes/pmgen/xilinx_dsp48a_pm.h passes/pmgen/xilinx_dsp_CREG_pm.h passes/pmgen/xilinx_dsp_cascade_pm.h
$(BUILD_DIR)/passes/pmgen/microchip_dsp.o: passes/pmgen/microchip_dsp_pm.h passes/pmgen/microchip_dsp_CREG_pm.h passes/pmgen/microchip_dsp_cascade_pm.h
$(BUILD_DIR)/passes/pmgen/peepopt.o: passes/pmgen/peepopt_pm.h
$(BUILD_DIR)/passes/pmgen/peepopt_pm.h: passes/pmgen/pmgen.py $(PEEPOPT_PATTERN)
$(BUILD_DIR)/passes/pmgen/xilinx_srl.o: passes/pmgen/xilinx_srl_pm.h

# techlibs/common/Makefile.inc
$(BUILD_DIR)/techlibs/common/simlib_help.inc: techlibs/common/cellhelp.py techlibs/common/simlib.v
	$(Q) mkdir -p techlibs/common
	$(P) $(PYTHON_EXECUTABLE) $^ > $@.new
	$(Q) mv $@.new $@

$(BUILD_DIR)/techlibs/common/simcells_help.inc: techlibs/common/cellhelp.py techlibs/common/simcells.v
	$(Q) mkdir -p techlibs/common
	$(P) $(PYTHON_EXECUTABLE) $^ > $@.new
	$(Q) mv $@.new $@

$(BUILD_DIR)/kernel/register.o: $(BUILD_DIR)/techlibs/common/simlib_help.inc $(BUILD_DIR)/techlibs/common/simcells_help.inc

# techlibs/quicklogic/Makefile.inc
$(BUILD_DIR)/techlibs/quicklogic/qlf_k6n10f/bram_types_sim.v: techlibs/quicklogic/qlf_k6n10f/generate_bram_types_sim.py
	$(P) mkdir -p $(dir $@) && $(PYTHON_EXECUTABLE) $^ $@

$(BUILD_DIR)/techlibs/quicklogic/ql_dsp_macc.o: techlibs/quicklogic/ql_dsp_macc_pm.h

# techlibs/gatemate/Makefile.inc
$(BUILD_DIR)/techlibs/gatemate/lut_tree_lib.mk: techlibs/gatemate/make_lut_tree_lib.py
	$(Q) mkdir -p techlibs/gatemate
	$(P) $(PYTHON_EXECUTABLE) $<
	$(Q) touch $@

$(BUILD_DIR)/techlibs/gatemate/lut_tree_cells.genlib: $(BUILD_DIR)/techlibs/gatemate/lut_tree_lib.mk
$(BUILD_DIR)/techlibs/gatemate/lut_tree_map.v: $(BUILD_DIR)/techlibs/gatemate/lut_tree_lib.mk

# frontends/rtlil/Makefile.inc
$(BUILD_DIR)/frontends/rtlil/rtlil_parser.tab.cc: frontends/rtlil/rtlil_parser.y
	$(Q) mkdir -p $(dir $@)
	$(P) $(BISON) -o $@ -d -r all -b frontends/rtlil/rtlil_parser $<

$(BUILD_DIR)/frontends/rtlil/rtlil_parser.tab.hh: frontends/rtlil/rtlil_parser.tab.cc

$(BUILD_DIR)/frontends/rtlil/rtlil_lexer.cc: frontends/rtlil/rtlil_lexer.l
	$(Q) mkdir -p $(dir $@)
	$(P) flex -o frontends/rtlil/rtlil_lexer.cc $<

# frontends/verilog/Makefile.inc
$(BUILD_DIR)/frontends/verilog/verilog_parser.tab.cc: frontends/verilog/verilog_parser.y
	$(Q) mkdir -p $(dir $@)
	$(P) $(BISON) -Wall -Werror -o $@ -d -r all -b frontends/verilog/verilog_parser $<

$(BUILD_DIR)/frontends/verilog/verilog_parser.tab.hh: frontends/verilog/verilog_parser.tab.cc

$(BUILD_DIR)/frontends/verilog/verilog_lexer.cc: frontends/verilog/verilog_lexer.l frontends/verilog/verilog_parser.tab.cc
	$(Q) mkdir -p $(dir $@)
	$(P) flex -o frontends/verilog/verilog_lexer.cc $<

$(BUILD_DIR)/frontends/verilog/verilog_parser.tab.o: CXXFLAGS += -DYYMAXDEPTH=10000000

# passes/pmgen/Makefile.inc
$(BUILD_DIR)/%_pm.h: passes/pmgen/pmgen.py %.pmg
	$(P) mkdir -p $(dir $@) && $(PYTHON_EXECUTABLE) $< -o $@ -p $(subst _pm.h,,$(notdir $@)) $(filter-out $<,$^)

$(BUILD_DIR)/passes/pmgen/test_pmgen.o: passes/pmgen/test_pmgen_pm.h passes/pmgen/ice40_dsp_pm.h passes/pmgen/peepopt_pm.h passes/pmgen/xilinx_srl_pm.h
$(BUILD_DIR)/passes/pmgen/ice40_dsp.o: passes/pmgen/ice40_dsp_pm.h
$(BUILD_DIR)/passes/pmgen/ice40_wrapcarry.o: passes/pmgen/ice40_wrapcarry_pm.h
$(BUILD_DIR)/passes/pmgen/xilinx_dsp.o: passes/pmgen/xilinx_dsp_pm.h passes/pmgen/xilinx_dsp48a_pm.h passes/pmgen/xilinx_dsp_CREG_pm.h passes/pmgen/xilinx_dsp_cascade_pm.h
$(BUILD_DIR)/passes/pmgen/microchip_dsp.o: passes/pmgen/microchip_dsp_pm.h passes/pmgen/microchip_dsp_CREG_pm.h passes/pmgen/microchip_dsp_cascade_pm.h
$(BUILD_DIR)/passes/pmgen/peepopt.o: passes/pmgen/peepopt_pm.h
$(BUILD_DIR)/passes/pmgen/xilinx_srl.o: passes/pmgen/xilinx_srl_pm.h

$(BUILD_DIR)/passes/pmgen/peepopt_pm.h: passes/pmgen/pmgen.py $(PEEPOPT_PATTERN)
	$(P) mkdir -p passes/pmgen && $(PYTHON_EXECUTABLE) $< -o $@ -p peepopt $(filter-out $<,$^)
