#!/usr/bin/env -S make -rR -Oline -f
.ONESHELL:
override SHELL := /bin/bash
override .SHELLFLAGS := -e -u -o pipefail -O nullglob -O extglob -O globstar -c

override this_mk.file := $(abspath $(lastword ${MAKEFILE_LIST}))
override this_mk.dir := $(patsubst /%/,/%,$(dir ${this_mk.file}))

override chr.quot := '#'# Single quote; everything starting from the first `#` is a comment intended to fix syntax highlighting.
override chr.percent := %

sh_quote = ${chr.quot}$(subst ${chr.quot},${chr.quot}\'${chr.quot},$(strip ${1}))${chr.quot}

sh_quote_list = $(foreach _v,$(strip ${1}),${chr.quot}$(subst ${chr.quot},${chr.quot}\'${chr.quot},${_v})${chr.quot})

#───────────────────────────────────────────────────────────────────────────────
# Configuration
#───────────────────────────────────────────────────────────────────────────────

REPO_DIR := ${this_mk.dir}
INSTALL_DIR := ${this_mk.dir}/out/current

ENABLE_ASAN ?= 0
ifneq (${CC},)
build_config += CC:=${CC}
endif
ifneq (${CXX},)
build_config += CXX:=${CXX}
endif
ifneq (${LD},)
build_config += LD:=${LD}
endif
ifeq ($(strip ${ENABLE_ASAN}),1)
build_config += CFG_BUILD_TYPE=asan
endif

$(info ------------------------------------------------------------------------)
$(foreach var,REPO_DIR INSTALL_DIR ENABLE_ASAN CC CXX,\
  $(info $(shell \
    printf '${chr.percent}-32s = ${chr.percent}s\n' ${var} $(call sh_quote,${${var}});\
  ))\
)
$(info ------------------------------------------------------------------------)

#───────────────────────────────────────────────────────────────────────────────

.PHONY: all
all: install-plugins

#───────────────────────────────────────────────────────────────────────────────
# Surelog
#───────────────────────────────────────────────────────────────────────────────

.PHONY: clean-surelog
clean-surelog:
	${MAKE} clean@surelog ${build_config}

.PHONY: build-surelog
build-surelog:
	${MAKE} build@surelog ${build_config}

.PHONY: install-surelog
install-surelog:
	${MAKE} install@surelog ${build_config}

#───────────────────────────────────────────────────────────────────────────────
# Yosys
#───────────────────────────────────────────────────────────────────────────────

YOSYS_SRC_DIR := ${REPO_DIR}/third_party/yosys

.PHONY: clean-yosys
clean-yosys:
	${MAKE} clean@yosys ${build_config}

.PHONY: build-yosys
build-yosys:
	${MAKE} build@yosys ${build_config}

.PHONY: install-yosys
install-yosys:
	${MAKE} install@yosys ${build_config}

#───────────────────────────────────────────────────────────────────────────────
# fakedlclose
#───────────────────────────────────────────────────────────────────────────────

.PHONY: clean-fakedlclose
clean-fakedlclose:
	${MAKE} clean@fakedlclose ${build_config}

.PHONY: build-fakedlclose
build-fakedlclose:
	${MAKE} build@fakedlclose ${build_config}

.PHONY: install-fakedlclose
install-fakedlclose:
	${MAKE} install@fakedlclose ${build_config}

#───────────────────────────────────────────────────────────────────────────────
# Plugin
#───────────────────────────────────────────────────────────────────────────────

# TODO: migrate to new Makefiles
.PHONY: build-plugin
clean-plugin:
	export PATH=${INSTALL_DIR}/bin:$${PATH}
	${MAKE} clean@systemverilog-plugin ${build_config}

.PHONY: build-plugin
build-plugin:
	export PATH=${INSTALL_DIR}/bin:$${PATH}
	${MAKE} build@systemverilog-plugin ${build_config}

.PHONY: install-plugin
install-plugin: install-fakedlclose
	export PATH=${INSTALL_DIR}/bin:$${PATH}
	${MAKE} install@systemverilog-plugin ${build_config}

# For backwards compatibility
.PHONY: clean-plugins
clean-plugins: clean-plugin

.PHONY: build-plugins
build-plugins: build-plugin

.PHONY: install-plugins
install-plugins: install-plugin

.NOTPARALLEL: clean-surelog clean-yosys clean-plugin clean-fakedlclose \
	build-surelog build-yosys build-plugin build-fakedlclose \
	install-surelog install-yosys install-plugin install-fakedlclose
