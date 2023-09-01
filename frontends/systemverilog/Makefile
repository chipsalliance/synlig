# Copyright 2020-2022 F4PGA Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

PLUGIN_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

NAME = systemverilog
SOURCES = UhdmAst.cc \
          uhdmastfrontend.cc \
          uhdmcommonfrontend.cc \
          uhdmsurelogastfrontend.cc \
          third_party/yosys/const2ast.cc \
          third_party/yosys/simplify.cc

# Directory to search for Surelog and UHDM libraries
UHDM_INSTALL_DIR ?= /usr/local

# Tell pkg-config to look in the provided install path first.
# PKG_CONFIG_PATH and PKG_CONFIG_PATH_FOR_TARGET are search paths it looks in
# so set the environment variables and prefix with our local install first
PKG_CONFIG_INVOKE = \
   PKG_CONFIG_PATH=$(UHDM_INSTALL_DIR)/lib/pkgconfig:${PKG_CONFIG_PATH} \
   PKG_CONFIG_PATH_FOR_TARGET=$(UHDM_INSTALL_DIR)/lib/pkgconfig:${PKG_CONFIG_PATH_FOR_TARGET} \
   pkg-config

# Directory containing this Makefile
TOP_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

_MAKEFILES := $(abspath $(filter-out %.d,$(MAKEFILE_LIST)))

# Either find yosys in system and use its path or use the given path
YOSYS_PATH ?= $(realpath $(dir $(shell command -v yosys))/..)

# Find yosys-config, throw an error if not found
YOSYS_CONFIG = $(YOSYS_PATH)/bin/yosys-config
ifeq (,$(wildcard $(YOSYS_CONFIG)))
  $(error "Didn't find 'yosys-config' under '$(YOSYS_PATH)'")
endif

CXX ?= $(shell $(YOSYS_CONFIG) --cxx)
CXXFLAGS := $(shell $(YOSYS_CONFIG) --cxxflags) $(CXXFLAGS) #-DSDC_DEBUG
LDFLAGS := $(shell $(YOSYS_CONFIG) --ldflags) $(LDFLAGS)
LDLIBS := $(shell $(YOSYS_CONFIG) --ldlibs) $(LDLIBS)
EXTRA_FLAGS ?=

YOSYS_DATA_DIR = $(DESTDIR)$(shell $(YOSYS_CONFIG) --datdir)
YOSYS_PLUGINS_DIR = $(YOSYS_DATA_DIR)/plugins

BUILD_DIR := $(PLUGIN_DIR)/../../build/systemverilog-plugin

# Filled below with all object file paths
_ALL_OBJECTS :=
# Filled below with all build directory paths
_ALL_BUILD_SUBDIRS :=

# Default rule

.PHONY: all
all: build

# Object files

define _process-single-source-file
_source_abs := $(abspath $(addprefix $(PLUGIN_DIR)/,$(source)))
_object_abs := $(abspath $(addprefix $(BUILD_DIR)/,$(source).o))
_object_dir := $(abspath $(dir $(_object_abs)))
_ALL_OBJECTS += $(_object_abs)
_ALL_BUILD_SUBDIRS += $(_object_dir)

-include $(abspath $(addprefix $(BUILD_DIR)/,$(source).d))

$(_object_abs): TARGET_SOURCES := $(_source_abs)
$(_object_abs): $(_source_abs) | $(_object_dir)
endef
$(foreach source,$(SOURCES),$(eval $(value _process-single-source-file)))

$(_ALL_OBJECTS): $(_MAKEFILES)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(EXTRA_FLAGS) -MMD -c -o $@ $(TARGET_SOURCES)

# Objects list for the purpose of adding extra dependencies after inclusion.
# Example use: `$(OBJECTS): $(BUILD_DIR)/some-file.h`
OBJECTS := $(_ALL_OBJECTS)

# Shared library

SO_LIB := $(BUILD_DIR)/$(NAME).so
_ALL_BUILD_SUBDIRS += $(abspath $(dir $(SO_LIB)))

$(SO_LIB): $(_ALL_OBJECTS) $(_MAKEFILES) | $(abspath $(dir $(SO_LIB)))
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -shared -o $@ $(_ALL_OBJECTS) $(LDLIBS)

.PHONY: $(NAME).so
$(NAME).so: $(SO_LIB)

# Tests

.PHONY: test test_clean
ifneq ($(wildcard $(PLUGIN_DIR)/tests/Makefile),)
test:
	@$(MAKE) -C tests all
test_clean:
	$(MAKE) -C tests clean
else
test:
test_clean:
endif

# Build

.PHONY: build
build: $(NAME).so

# Installation

$(YOSYS_PLUGINS_DIR)/$(NAME).so: $(SO_LIB) | $(YOSYS_PLUGINS_DIR)
	install -D $(SO_LIB) $@

.PHONY: install_plugin
install_plugin: $(YOSYS_PLUGINS_DIR)/$(NAME).so

.PHONY: install
install: install_plugin

# Cleanup

clean: test_clean
	rm -rf $(BUILD_DIR)

# Other

$(sort $(_ALL_BUILD_SUBDIRS)):
	mkdir -p $@

$(YOSYS_PLUGINS_DIR):
	@mkdir -p $@

PMGEN_PY := $(TOP_DIR)/pmgen.py

$(PMGEN_PY):
	@$(MAKE) -C $(TOP_DIR) pmgen.py

# A litmus-test: make compilation fail if pkg-config fails
.SECONDARY: $(BUILD_DIR)/.$(NAME)-deps-test
$(BUILD_DIR)/.$(NAME)-deps-test:
	$(PKG_CONFIG_INVOKE) --cflags Surelog

${SO_LIB}: | $(BUILD_DIR)/.$(NAME)-deps-test

CXXFLAGS += -std=c++17 -Wall -W -Wextra \
            -Wno-deprecated-declarations \
            -Wno-unused-parameter \
            $(shell $(PKG_CONFIG_INVOKE) --cflags Surelog)

LDFLAGS += $(shell $(PKG_CONFIG_INVOKE) --libs-only-L Surelog)

LDLIBS += $(shell $(PKG_CONFIG_INVOKE) --libs-only-l --libs-only-other Surelog)
