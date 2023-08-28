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
ENABLE_DEBUG := 0
SYSTEMVERILOG_PLUGIN_ONLY := 0

ifeq ($(strip ${ENABLE_ASAN}),1)
# Force debug config when using ASAN
override ENABLE_DEBUG := 1
endif

CC ?= cc
CXX ?= c++
export CC
export CXX

$(info ------------------------------------------------------------------------)
$(foreach var,REPO_DIR INSTALL_DIR ENABLE_ASAN SYSTEMVERILOG_PLUGIN_ONLY CC CXX,\
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

SURELOG_SRC_DIR := ${REPO_DIR}/Surelog
SURELOG_BUILD_DIR := ${REPO_DIR}/Surelog/build

surelog_build_type:=Release
ifeq ($(strip ${ENABLE_DEBUG}),1)
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

YOSYS_SRC_DIR := ${REPO_DIR}/yosys
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
		SANITIZER:=address

ifeq ($(findstring clang,${CC}),clang)
build-yosys install-yosys: export override CXXFLAGS += -fsanitize-address-use-after-return=always
endif
endif

ifeq ($(strip ${ENABLE_DEBUG}),1)
yosys_make_args += \
		STRIP:=/bin/true \
		ENABLE_DEBUG:=1
endif

.PHONY: clean-yosys
clean-yosys:
	${MAKE} -C ${YOSYS_SRC_DIR} ${yosys_make_args} clean || :
	(
		cd ${YOSYS_SRC_DIR}
		git clean -fdX *
		rm -rf abc
	)

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
	${MAKE} -C ${FAKEDLCLOSE_SRC_DIR} clean || :

.PHONY: build-fakedlclose
build-fakedlclose:
	${MAKE} -C ${FAKEDLCLOSE_SRC_DIR}

.PHONY: install-fakedlclose
install-fakedlclose: build-fakedlclose | ${INSTALL_DIR}
	${MAKE} -C ${FAKEDLCLOSE_SRC_DIR} INSTALL_DIR:=${INSTALL_DIR} install

#───────────────────────────────────────────────────────────────────────────────
# Plugins
#───────────────────────────────────────────────────────────────────────────────

PLUGINS_SRC_DIR := ${REPO_DIR}/yosys-f4pga-plugins
plugins_make_args := UHDM_INSTALL_DIR:=${INSTALL_DIR} CC:=${CC} CXX:=${CXX}

ifeq ($(strip ${ENABLE_ASAN}),1)
plugins_build_deps += build-fakedlclose
plugins_install_deps += install-fakedlclose
else
plugins_build_deps :=
plugins_install_deps :=
endif

ifeq ($(strip ${ENABLE_DEBUG}),1)
plugins_make_args += EXTRA_FLAGS:='-g -Og'
endif

ifeq ($(strip ${SYSTEMVERILOG_PLUGIN_ONLY}),1)
plugins_make_clean_targets := clean_systemverilog clean_uhdm
plugins_make_build_targets := systemverilog.so uhdm.so
plugins_make_install_targets := install_systemverilog install_uhdm
else
plugins_make_clean_targets := clean
plugins_make_build_targets := plugins
plugins_make_install_targets := install
endif

.PHONY: clean-plugins
clean-plugins:
	export PATH=${INSTALL_DIR}/bin:$${PATH}
	${MAKE} -C ${PLUGINS_SRC_DIR} ${plugins_make_args} ${plugins_make_clean_targets} || :

.PHONY: build-plugins
build-plugins: install-yosys install-surelog ${plugins_build_deps}
	cp -u ${YOSYS_SRC_DIR}/passes/pmgen/pmgen.py ${PLUGINS_SRC_DIR}/
	export PATH=${INSTALL_DIR}/bin:$${PATH}
	${MAKE} -C ${PLUGINS_SRC_DIR} --no-print-directory ${plugins_make_args} ${plugins_make_build_targets}

.PHONY: install-plugins
install-plugins: build-plugins ${plugins_install_deps} | ${INSTALL_DIR}
	export PATH=${INSTALL_DIR}/bin:$${PATH}
	${MAKE} -C ${PLUGINS_SRC_DIR} --no-print-directory ${plugins_make_args} ${plugins_make_install_targets}

