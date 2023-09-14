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
INSTALL_DIR := ${this_mk.dir}/image

ENABLE_ASAN := 0

CC ?= cc
CXX ?= c++
export CC
export CXX

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

${INSTALL_DIR}:
	mkdir -p $@

#───────────────────────────────────────────────────────────────────────────────
# Surelog
#───────────────────────────────────────────────────────────────────────────────

SURELOG_SRC_DIR := ${REPO_DIR}/third_party/surelog
SURELOG_BUILD_DIR := ${REPO_DIR}/third_party/surelog/build

surelog_build_type:=Release
ifeq ($(strip ${ENABLE_ASAN}),1)
surelog_build_type:=Debug
endif

.PHONY: clean-surelog
clean-surelog:
	rm -rf ${SURELOG_BUILD_DIR}

.PHONY: build-surelog
build-surelog:
	cmake \
			-DCMAKE_BUILD_TYPE=${surelog_build_type} \
			-DCMAKE_INSTALL_PREFIX=$(call sh_quote,${INSTALL_DIR}) \
			-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
			-S $(call sh_quote,${SURELOG_SRC_DIR}) -B $(call sh_quote,${SURELOG_BUILD_DIR})
	$(MAKE) -C $(call sh_quote,${SURELOG_BUILD_DIR}) --no-print-directory

.PHONY: install-surelog
install-surelog: build-surelog | ${INSTALL_DIR}
	$(MAKE) -C $(call sh_quote,${SURELOG_BUILD_DIR}) --no-print-directory install

#───────────────────────────────────────────────────────────────────────────────
# Yosys
#───────────────────────────────────────────────────────────────────────────────

YOSYS_SRC_DIR := ${REPO_DIR}/third_party/yosys
yosys_make_args := PREFIX:=${INSTALL_DIR}

ifeq ($(findstring clang,${CC}),clang)
yosys_make_args += \
		CONFIG:=clang \
		CC:=${CC} \
		CXX:=${CC} \
		LD:=${CXX}
else
yosys_make_args += \
		CONFIG:=gcc
endif

ifeq ($(strip ${ENABLE_ASAN}),1)
yosys_make_args += \
		STRIP:=/bin/true \
		SANITIZER:=address \
		ENABLE_DEBUG:=1

ifeq ($(findstring clang,${CC}),clang)
build-yosys install-yosys: export override CXXFLAGS += -fsanitize-address-use-after-return=always
endif
endif

.PHONY: clean-yosys
clean-yosys:
	${MAKE} -C ${YOSYS_SRC_DIR} ${yosys_make_args} clean

.PHONY: build-yosys
build-yosys:
	${MAKE} -C ${YOSYS_SRC_DIR} --no-print-directory ${yosys_make_args}

.PHONY: install-yosys
install-yosys: build-yosys | ${INSTALL_DIR}
	${MAKE} -C ${YOSYS_SRC_DIR} --no-print-directory ${yosys_make_args} install

#───────────────────────────────────────────────────────────────────────────────
# fakedlclose
#───────────────────────────────────────────────────────────────────────────────

FAKEDLCLOSE_SRC_DIR := ${REPO_DIR}/lib/fakedlclose

.PHONY: clean-fakedlclose
clean-fakedlclose:
	${MAKE} -C ${FAKEDLCLOSE_SRC_DIR} clean

.PHONY: build-fakedlclose
build-fakedlclose:
	${MAKE} -C ${FAKEDLCLOSE_SRC_DIR}

.PHONY: install-fakedlclose
install-fakedlclose: build-fakedlclose | ${INSTALL_DIR}
	${MAKE} -C ${FAKEDLCLOSE_SRC_DIR} INSTALL_DIR:=${INSTALL_DIR} install

#───────────────────────────────────────────────────────────────────────────────
# Plugin
#───────────────────────────────────────────────────────────────────────────────

plugin_make_args := UHDM_INSTALL_DIR:=${INSTALL_DIR} CC:=${CC} CXX:=${CXX}

ifeq ($(strip ${ENABLE_ASAN}),1)
plugin_make_args += EXTRA_FLAGS:='-g'

plugin_build_deps += build-fakedlclose
plugin_install_deps += install-fakedlclose
else
plugin_build_deps :=
plugin_install_deps :=
endif

clean-plugin:
	export PATH=${INSTALL_DIR}/bin:$${PATH}
	${MAKE} -C frontends/systemverilog ${plugin_make_args} clean

.PHONY: build-plugin
build-plugin: install-yosys install-surelog ${plugin_build_deps}
	export PATH=${INSTALL_DIR}/bin:$${PATH}
	${MAKE} -C frontends/systemverilog --no-print-directory ${plugin_make_args} build

.PHONY: install-plugin
install-plugin: build-plugin ${plugin_install_deps} | ${INSTALL_DIR}
	export PATH=${INSTALL_DIR}/bin:$${PATH}
	${MAKE} -C frontends/systemverilog --no-print-directory ${plugin_make_args} install

# For backwards compatibility
.PHONY: clean-plugins
clean-plugins: clean-plugin

.PHONY: build-plugins
build-plugins: build-plugin

.PHONY: install-plugins
install-plugins: install-plugin

