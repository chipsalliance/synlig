.ONESHELL:
override SHELL := /bin/bash
override .SHELLFLAGS := -e -u -o pipefail -O nullglob -O extglob -c

override this_mk.file := $(abspath $(lastword ${MAKEFILE_LIST}))
override this_mk.dir := $(patsubst /%/,/%,$(dir ${this_mk.file}))

override define chr.nl :=


endef

override chr.empty :=
override chr.space := ${chr.empty} ${chr.empty}
override chr.quot  := '#'# the comment is just for fixing syntax highlighting.

sh_quote = ${chr.quot}$(subst ${chr.quot},${chr.quot}\'${chr.quot},$(strip ${1}))${chr.quot}

sh_quote_list = $(foreach _v,$(strip ${1}),${chr.quot}$(subst ${chr.quot},${chr.quot}\'${chr.quot},${_v})${chr.quot})

#───────────────────────────────────────────────────────────────────────────────
# Configuration
#───────────────────────────────────────────────────────────────────────────────

# General paths and constants
PATCH_DIR := $(abspath ${this_mk.dir}/..)
BUILD_DIR := ${this_mk.dir}/build
OPENTITAN_DEPS_MK_FILE := ${BUILD_DIR}/opentitan-deps.mk
PASSLIST_FILE := ${this_mk.dir}/ot-cores-passlist.txt
SKIPLIST_FILE := ${this_mk.dir}/ot-cores-skiplist.txt
export OPENTITAN_DIR := $(abspath ${this_mk.dir}/../../../third_party/opentitan)

# -1 == no minimum
export MIN_FREE_MEM_TO_START_TEST := -1
export VMEM_LIMIT_KB := unlimited
export LOG_DUMP_LINES_LIMIT := 100

# Opentitan top core specification, used by Fusesoc for graph generation only.
DESIGN_CORE_NAME := lowrisc:systems_custom_tiny:chip_custom_tiny_nexysvideo:0.1
DESIGN_CORE_SV := ${OPENTITAN_DIR}/hw/top_custom_tiny/rtl/top_custom_tiny.sv
DESIGN_CORE_HW_DIR := ${OPENTITAN_DIR}/hw/top_custom_tiny
DESIGN_CORE_HJSON := ${DESIGN_CORE_HW_DIR}/data/top_custom_tiny.hjson

# Derived values
DESIGN_CORE := $(subst :,.,${DESIGN_CORE_NAME})
FUSESOC_DEPS_DOT := ${OPENTITAN_DIR}/$(subst :,_,${DESIGN_CORE_NAME}).dot
DEPS_DOT := ${BUILD_DIR}/opentitan-deps.dot
export VENV_DIR := ${BUILD_DIR}/opentitan-venv

#───────────────────────────────────────────────────────────────────────────────
# Cores lists
#───────────────────────────────────────────────────────────────────────────────

# Allow running `help` and `clean[-results]` without generating
# ${OPENTITAN_DEPS_MK_FILE}.  This is normally forced by include if it does
# not exist.  Also filter out `gen-opentitan-deps-mk` to avoid `Nothing to be
# done for 'gen-opentitan-deps-mk'` message.
ifneq ($(filter-out gen-opentitan-deps-mk help clean-results clean,${MAKECMDGOALS}),)

include ${OPENTITAN_DEPS_MK_FILE}

else # ifneq ($(filter-out gen-opentitan-deps-mk help clean-results clean,${MAKECMDGOALS}),)

ALL_CORES :=
TOP_CORES :=

endif # ifneq ($(filter-out gen-opentitan-deps-mk help clean-results clean,${MAKECMDGOALS}),)


# SKIPPED_CORES  - Never tested cores. Always assumed to pass.
# PASSING_CORES  - Cores initially assumed to pass testing.
#                  Tested only when any of its users failed a test.
# TESTED_CORES   - Cores tested normally.
#                  Marked without testing as `dependency-failed` when any
#                  of its dependencies failed.
# TOP_DOWN_CORES - Similar to PASSING_CORES, but uses `test-pass` and
#                  `test-fail` as its statuses.

ifneq (${SKIPLIST_FILE},)
SKIPPED_CORES := $(shell sed -e 's/:/./g' -e 's/[^-a-zA-Z0-9_.:]/_/g' ${SKIPLIST_FILE})
else
SKIPPED_CORES :=
endif # ifneq (${SKIPLIST_FILE},)

ifneq (${PASSLIST_FILE},)
PASSING_CORES := $(shell sed -e 's/:/./g' -e 's/[^-a-zA-Z0-9_.:]/_/g' ${PASSLIST_FILE})
else
PASSING_CORES :=
endif # ifneq (${PASSLIST_FILE},)

TOP_DOWN_TEST ?= 0
ifeq ($(strip ${TOP_DOWN_TEST}),1)
TOP_DOWN_CORES := $(filter-out ${TOP_CORES} ${PASSING_CORES} ${SKIPPED_CORES},${ALL_CORES})
else # ifeq ($(strip ${TOP_DOWN_TEST}),1)
TOP_DOWN_CORES :=
endif # ifeq ($(strip ${TOP_DOWN_TEST}),1)

TESTED_CORES := $(filter-out ${SKIPPED_CORES} ${PASSING_CORES} ${TOP_DOWN_CORES},${ALL_CORES})

# Make sure there is no overlap between SKIPPED_CORES and PASSING_CORES.
ifneq ($(filter ${SKIPPED_CORES},${PASSING_CORES}),)
override define err_msg :=
Skiplist and Passlist contain common elements:
$(subst ${chr.nl}${chr.space},${chr.nl},$(foreach core,$(filter ${SKIPPED_CORES},${PASSING_CORES}),- ${core}${chr.nl}))
endef
$(error ${err_msg})
endif # ifneq ($(filter ${SKIPLIST_FILE},${PASS_LIST_FILE}),)

#───────────────────────────────────────────────────────────────────────────────
# General targets
#───────────────────────────────────────────────────────────────────────────────

.DEFAULT_GOAL := test
.PHONY: test
targetdesc.test := Test all cores.
test : ${ALL_CORES}


.PHONY: help
targetdesc.help := Print list of common targets.
help :
	@printf '%-23s %s\n' $(foreach var,$(filter targetdesc.%,${.VARIABLES}), '$(patsubst targetdesc.%,%,${var})' '${${var}}')


.PHONY: clean-results
targetdesc.clean-results := Remove all test results.
clean-results :
	rm -rf ${BUILD_DIR}/results
	rm -rf ${BUILD_DIR}/summary.md


.PHONY: clean
targetdesc.clean := Remove all generated files.
clean : clean-opentitan-patch
	rm -rf ${BUILD_DIR}


${BUILD_DIR} :
	@mkdir -p $@

#───────────────────────────────────────────────────────────────────────────────
# Virtualenv & Opentitan patches
#───────────────────────────────────────────────────────────────────────────────

opentitan_patch := ${OPENTITAN_DIR}/.gitpatch

${opentitan_patch} :
	cd ${OPENTITAN_DIR}
	orig_rev=$$(git rev-parse HEAD)
	git apply ${PATCH_DIR}/0001-Add-core-files-for-processing-Earlgrey-in-Yosys.patch
	git apply ${PATCH_DIR}/0002-use-Edalize-fork-for-SystemVerilog-in-Yosys.patch
	printf '%s\n' "$$orig_rev" > $@

.PHONY: clean-opentitan-patch
targetdesc.clean-opentitan-patch := Unapply patches in Opentitan repo.
clean-opentitan-patch :
	if [[ -e ${opentitan_patch} ]]; then
		cd ${OPENTITAN_DIR}
		git reset --hard $$(< ${opentitan_patch})
		rm -f ${opentitan_patch}
		git clean -f
	fi

.PHONY: env
targetdesc.env := Create virtual environment.
env: ${VENV_DIR}

.DELETE_ON_ERROR: ${VENV_DIR}
${VENV_DIR} : | ${BUILD_DIR}
	virtualenv ${VENV_DIR}
	. ${VENV_DIR}/bin/activate
	pip install -r ${OPENTITAN_DIR}/python-requirements.txt
	pip install pygraphviz
	(
		cd ${BUILD_DIR}
		git clone --depth 1 https://github.com/lowRISC/fusesoc.git -b ot-0.3
		(
			cd fusesoc
			git apply ${PATCH_DIR}/0001-allow-processing-cores-without-top-module.patch
			pip install --upgrade --force-reinstall --no-dependencies .
		)
	)

${DESIGN_CORE_SV} : | ${opentitan_patch} ${VENV_DIR}
	. ${VENV_DIR}/bin/activate
	cd ${DESIGN_CORE_HW_DIR}
	${OPENTITAN_DIR}/util/topgen.py -t ${DESIGN_CORE_HJSON} -o . -v

.DELETE_ON_ERROR: ${FUSESOC_DEPS_DOT}
.INTERMEDIATE: ${FUSESOC_DEPS_DOT}
${FUSESOC_DEPS_DOT} : | ${opentitan_patch} ${VENV_DIR}
	. ${VENV_DIR}/bin/activate
	cd ${OPENTITAN_DIR}
	fusesoc --cores-root=. dep graph ${DESIGN_CORE_NAME} &> ${BUILD_DIR}/fusesoc_dep_graph.log

${DEPS_DOT} : ${FUSESOC_DEPS_DOT}
	mv ${FUSESOC_DEPS_DOT} ${DEPS_DOT}

.PHONY: gen-opentitan-deps-mk
targetdesc.gen-opentitan-deps-mk := Generate .mk file with list of cores and their dependecies.
gen-opentitan-deps-mk : ${OPENTITAN_DEPS_MK_FILE}

${OPENTITAN_DEPS_MK_FILE} : ${DEPS_DOT} | ${BUILD_DIR}
	. ${VENV_DIR}/bin/activate
	${this_mk.dir}/fusesoc_dot_to_makefile.py \
			--core-vars-prefix='' \
			--all-cores-var-name=ALL_CORES \
			--top-cores-var-name=TOP_CORES \
			${DEPS_DOT} \
			$@

#───────────────────────────────────────────────────────────────────────────────
# Core-specific targets
#───────────────────────────────────────────────────────────────────────────────

ifneq (${ALL_CORES},)


${BUILD_DIR}/results : ${BUILD_DIR}
	@mkdir -p $@

#┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
# Core paths getters

get_core_build_dir          = ${BUILD_DIR}/results/$(strip ${1})

get_core_name_file          = ${BUILD_DIR}/results/$(strip ${1})/name.txt
get_core_deps_file          = ${BUILD_DIR}/results/$(strip ${1})/deps.txt
get_core_users_file         = ${BUILD_DIR}/results/$(strip ${1})/users.txt

get_core_result_file        = ${BUILD_DIR}/results/$(strip ${1})/result.txt
get_core_fusesoc_log_file   = ${BUILD_DIR}/results/$(strip ${1})/fusesoc.log
get_core_fusesoc_stats_file = ${BUILD_DIR}/results/$(strip ${1})/fusesoc-stats.txt

#┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
# Core definitions generation

define gen_core_defs =

# passed variable: _core
# passed variable: _test_deps
_build_dir        := $(call get_core_build_dir,${_core})
_name_file        := $(call get_core_name_file,${_core})
_deps_file        := $(call get_core_deps_file,${_core})
_users_file       := $(call get_core_users_file,${_core})
_result_file      := $(call get_core_result_file,${_core})
_fusesoc_log_file := $(call get_core_fusesoc_log_file,${_core})

.PHONY: ${_core}

${_name_file} ${_deps_file} ${_users_file} : target.core := ${_core}
${_result_file} ${_core} : target.core := ${_core}
${_result_file} ${_core} : target.test_deps := ${_test_deps}

${_core} : | ${_result_file}

${_build_dir} :
	@mkdir -p $@

${_name_file} : | ${_build_dir}
	@printf '%s\n' $(call sh_quote,${core_names[${target.core}]})      > $@

${_deps_file} : | ${_build_dir}
	@printf '%s\n' $(call sh_quote_list,${core_deps[${target.core}]})  > $@

${_users_file} : | ${_build_dir}
	@printf '%s\n' $(call sh_quote_list,${core_users[${target.core}]}) > $@

${_result_file} : | ${_test_deps} ${_name_file} ${_deps_file} ${_users_file} ${_build_dir}

# Do not delete the log even when make failed.
.PRECIOUS: ${_fusesoc_log_file}

undefine _fusesoc_log_file
undefine _result_file
undefine _users_file
undefine _deps_file
undefine _name_file
undefine _build_dir

endef # define gen_core_defs

_test_deps =
$(foreach _core,${SKIPPED_CORES},$(eval $(value gen_core_defs)))
undefine _test_deps

_test_deps = ${core_users[${_core}]}
$(foreach _core,${PASSING_CORES},$(eval $(value gen_core_defs)))
undefine _test_deps

_test_deps = $(filter-out ${PASSING_CORES} ${TOP_DOWN_CORES},${core_deps[${_core}]})
$(foreach _core,${TESTED_CORES},$(eval $(value gen_core_defs)))
undefine _test_deps

_test_deps = ${core_users[${_core}]}
$(foreach _core,${TOP_DOWN_CORES},$(eval $(value gen_core_defs)))
undefine _test_deps


SKIPPED_CORES.result_files  := $(foreach _core,${SKIPPED_CORES},$(call get_core_result_file,${_core}))
PASSING_CORES.result_files  := $(foreach _core,${PASSING_CORES},$(call get_core_result_file,${_core}))
TESTED_CORES.result_files   := $(foreach _core,${TESTED_CORES},$(call get_core_result_file,${_core}))
TOP_DOWN_CORES.result_files := $(foreach _core,${TOP_DOWN_CORES},$(call get_core_result_file,${_core}))

# Delete result files of targets that were executing when error in Make happened.
.DELETE_ON_ERROR: ${SKIPPED_CORES.result_files} ${PASSING_CORES.result_files} ${TESTED_CORES.result_files}

#┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
# Snippets inserted to target's recipes for the supporting script use

define sh_target_common_defs =
	declare -r  THIS_SCRIPT_DIR=$(call sh_quote,${this_mk.dir})

	get_core_build_dir()          { printf '%s' $(call get_core_build_dir,"$${1}"); }

	get_core_name_file()          { printf '%s' $(call get_core_name_file,"$${1}"); }
	get_core_deps_file()          { printf '%s' $(call get_core_deps_file,"$${1}"); }
	get_core_users_file()         { printf '%s' $(call get_core_users_file,"$${1}"); }

	get_core_result_file()        { printf '%s' $(call get_core_result_file,"$${1}"); }
	get_core_fusesoc_log_file()   { printf '%s' $(call get_core_fusesoc_log_file,"$${1}"); }
	get_core_fusesoc_stats_file() { printf '%s' $(call get_core_fusesoc_stats_file,"$${1}"); }
endef # define sh_result_file_target_common_defs

define sh_result_file_target_common_defs =
	${sh_target_common_defs}
	declare -r  TARGET_RESULT_FILE=$(call sh_quote,$@)
	declare -r  TARGET_CORE=$(call sh_quote,${target.core})
	declare -r  TARGET_CORE_NAME=$(call sh_quote,${core_names[${target.core}]})
	declare -ra TARGET_TEST_DEPS=($(call sh_quote_list,${target.test_deps}))
endef # define sh_result_file_target_common_defs

#┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
# SKIPPED_CORES
#
# Each target just writes `skip-skiplist` status to its `results.txt` file.

${SKIPPED_CORES.result_files} :
	@#
	${sh_result_file_target_common_defs}
	source ${this_mk.dir}/Makefile.scripts.sh
	process_skipped_core
	print_result $(call sh_quote,${target.core})

#┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
# PASSING_CORES
#
# Each target (or, more preciselly, its `results.txt` file) depends on its
# users (i.e. predecessor in the graph). Each target runs a test if status of
# any of its users is `fail`. Otherwise `skip-passlist` is reported.

${PASSING_CORES.result_files} :
	@#
	${sh_result_file_target_common_defs}
	source ${this_mk.dir}/Makefile.scripts.sh
	process_passing_core
	print_result $(call sh_quote,${target.core})

#┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
# TESTED_CORES
#
# Each target (or, more preciselly, its `results.txt` file) depends on its
# dependencies (i.e. succesors in the graph). Each target runs a test if
# statuses of all its dependencies are `pass`. Otherwise
# `dependency-failed` is reported.

${TESTED_CORES.result_files} :
	@#
	${sh_result_file_target_common_defs}
	source ${this_mk.dir}/Makefile.scripts.sh
	process_tested_core
	print_result $(call sh_quote,${target.core})

#┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
# TOP_DOWN_CORES
#
# Each target (or, more preciselly, its `results.txt` file) depends on its
# users (i.e. predecessor in the graph). Each target runs a test if status of
# any of its users is `fail`. Otherwise `skip-passlist` is reported.
#
# Basically the same as PASSING_CORES, but with more suitable statuses.

${TOP_DOWN_CORES.result_files} :
	@#
	${sh_result_file_target_common_defs}
	source ${this_mk.dir}/Makefile.scripts.sh
	process_top_down_tested_core
	print_result $(call sh_quote,${target.core})


endif # ifneq (${ALL_CORES},)

#───────────────────────────────────────────────────────────────────────────────
# Summary printing targets
#───────────────────────────────────────────────────────────────────────────────

ifneq (${ALL_CORES},)

.PHONY: summary
targetdesc.summary := Print tests summary.
summary :
	@#
	${sh_target_common_defs}
	source ${this_mk.dir}/Makefile.scripts.sh
	print_summary $(call sh_quote_list,${ALL_CORES})


.PHONY: summary.md
targetdesc.summary.md := Generate tests summary in Markdown.
summary.md : ${BUILD_DIR}/results/summary.md

${BUILD_DIR}/results/summary.md : | ${BUILD_DIR}/results
	@#
	${sh_target_common_defs}
	source ${this_mk.dir}/Makefile.scripts.sh
	# The following function exits with non-zero status when there is a new pass
	# or a tests from the passlist failed.
	rc=0
	print_summary_md $(call sh_quote_list,${ALL_CORES}) > $@ || rc=$$?
	if (( rc != 0 )); then
		touch ${BUILD_DIR}/results/.unexpected-test-result
	fi

.PHONY: check-status
check-status : | ${BUILD_DIR}/results/summary.md
	@[[ -e ${BUILD_DIR}/results/.unexpected-test-result ]] && exit 1
	exit 0

endif # ifneq (${ALL_CORES},)
