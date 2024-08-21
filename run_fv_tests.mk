#!/usr/bin/env -S make -rR -Otarget -f
.ONESHELL:
SHELL := bash
override .SHELLFLAGS := -e -u -o pipefail -O nullglob -O extglob -O globstar -c

override this_mk.file := $(abspath $(lastword ${MAKEFILE_LIST}))
override this_mk.dir := $(patsubst /%/,/%,$(dir ${this_mk.file}))

override chr.quot  := '#'# the comment is just for fixing syntax highlighting.

sh_quote = ${chr.quot}$(subst ${chr.quot},${chr.quot}\'${chr.quot},$(strip ${1}))${chr.quot}

sh_quote_list = $(foreach _v,$(strip ${1}),${chr.quot}$(subst ${chr.quot},${chr.quot}\'${chr.quot},${_v})${chr.quot})

#--------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------

TEST_SUITE_DIR ?=
TEST_SUITE_NAME ?=

REPO_DIR := ${this_mk.dir}

#--------------------------------------------------------------------------------
# Check and normalize configuration values

override help_only := 0
# Ignore most of the makefile when only help target has been requested
ifneq (${MAKECMDGOALS},)
ifeq ($(filter-out help,${MAKECMDGOALS}),)
override help_only := 1
endif
endif

ifeq (${help_only},0)

ifeq ($(strip ${TEST_SUITE_DIR}),)
ifeq (${MAKECMDGOALS},)
$(warning `TEST_SUITE_DIR` not specified)
# This makes `help` target default
override help_only := 1
else
$(error `TEST_SUITE_DIR` not specified)
endif
endif

override TEST_SUITE_DIR := $(abspath ${TEST_SUITE_DIR})
override REPO_DIR := $(abspath ${REPO_DIR})

endif # ifeq (${help_only},0)

#--------------------------------------------------------------------------------
# Help target
#--------------------------------------------------------------------------------

.PHONY: help
help :
	@#
	argv0=$(call sh_quote,${this_mk.file})
	argv0=$${argv0##*/}
	tab=$$'\t'
	printf '%s\n' \
			'USAGE' \
			"$${tab}$${argv0} -j<parallel_jobs_num> TEST_SUITE_DIR:=<test_suite_dir> TEST_SUITE_NAME:=<test_suite_name> [target]" \
			'' \
			'GENERIC TARGETS' \
			'' \
			"$${tab}test    Run all tests. Default." \
			"$${tab}list    List available tests (their target names)." \
			"$${tab}help    Print help message." \
			''

#--------------------------------------------------------------------------------
# Tests list
#--------------------------------------------------------------------------------

.PHONY: test list

ifeq (${help_only},0)

rel_v_files := $(shell cd ${TEST_SUITE_DIR}; echo */**/*.{v,sv})

test : ${rel_v_files}

list :
	@printf '%s\n' $(call sh_quote_list,${rel_v_files})

else

test : help

list : help

endif # ifeq (${help_only},0)

#--------------------------------------------------------------------------------
# Test-specific targets
#--------------------------------------------------------------------------------

ifeq (${help_only},0)

.PHONY: ${rel_v_files}
${rel_v_files} : % : ${TEST_SUITE_DIR}/%
	@#
	cd ${REPO_DIR}
	python3 ./tests/formal/run.py \
			--test-suite-name=$(call sh_quote,${TEST_SUITE_NAME}) \
			--test-suite-dir=$(call sh_quote,${TEST_SUITE_DIR}) \
			$< \
			|| :

endif # ifeq (${help_only},0)
