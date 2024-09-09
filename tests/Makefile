TESTS = $(shell find simple_tests -maxdepth 2 -name Makefile.in | cut -d\/ -f2 | sort -u)
TEST ?= simple_tests/onenet

root_dir:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

OUT_DIR = ${root_dir}/../out
COVARAGE_REPORT = ${root_dir}/build/coverage

TEST_DIR := $(realpath $(root_dir)/$(TEST))
MAIN_FILE ?= $(TEST_DIR)/main.cpp
YOSYS_TCL := $(TEST_DIR)/yosys_script.tcl

# this include should set $(TEST_FILES) and $(TOP_MODULE) variables
include $(TEST)/Makefile.in

# this variables use $(TOP_MODULE) that is set in included Makefile.in
TOP_UHDM = ${root_dir}/build/$(TOP_MODULE).uhdm
TOP_MAKEFILE := V$(TOP_MODULE).mk
# SURELOG_FLAGS are empty by default, unless set in Makefile.in

list:
	@echo "Available tests:"
	@for TEST in $(TESTS); do echo "- simple_tests/$$TEST"; done
	@echo "Please specify the TEST variable."

# ------------ Test targets ------------

uhdm/yosys/test-ast: clean-build surelog/parse
	(export TEST_DIR=${TEST_DIR} TEST_FILES="${TEST_FILES}" TOP_MODULE="${TOP_MODULE}" SURELOG_FLAGS="${SURELOG_FLAGS}" && \
	cd $(root_dir)/build && $(BINARY) -c $(YOSYS_TCL))

# ------------ Test helper targets ------------

surelog/parse: clean-build
	(cd ${root_dir}/build && \
		surelog -parse -sverilog -d coveruhdm -elabuhdm ${SURELOG_FLAGS} $(INCLUDE) $(TEST_FILES))
	cp ${root_dir}/build/slpp_all/surelog.uhdm ${TOP_UHDM}

# ------------ Clean targets ------------

clean-build:
	rm -rf $(root_dir)/build
	mkdir -p $(root_dir)/build

clean:: clean-build

# ------------ Other targets ------------

surelog/parse-earlgrey: clean-build
	(cd ${root_dir}/third_party/surelog/third_party/tests/Earlgrey_0_1/sim-icarus && \
		surelog -f Earlgrey_0_1.sl \
	)
	cp ${root_dir}/third_party/surelog/third_party/tests/Earlgrey_0_1/sim-icarus/slpp_all/surelog.uhdm ${TOP_UHDM}
