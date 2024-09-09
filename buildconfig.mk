# Default configuration for project Makefile.
#
# If you wish to modify configuration in this file just for your local builds,
# it is recommended to create `buildconfig.user.mk` file and put your overrides
# there.
#
# You can also set configuration variable through make command line arguments.
#--------------------------------------------------------------------------------

# One of: release, debug, asan
CFG_BUILD_TYPE := release

# Base directory for all build outputs.
CFG_BUILD_DIR = build/${CFG_BUILD_TYPE}/
PREFIX ?= /usr/local
DESTDIR ?=
CFG_OUT_DIR := $(DESTDIR)$(PREFIX)/

# Basic build tools
CC       ?= cc
CXX      ?= c++
LD       ?=
CFLAGS   ?=
CXXFLAGS ?=
LDFLAGS  ?=
LDLIBS   ?=

#--------------------------------------------------------------------------------
-include ${TOP_DIR}buildconfig.user.mk
