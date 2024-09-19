# Default configuration for project Makefile.
#
# If you wish to modify configuration in this file just for your local builds,
# it is recommended to create `buildconfig.user.mk` file and put your overrides
# there.
#
# You can also set configuration variable through make command line arguments.
#--------------------------------------------------------------------------------

# Base directory for all build outputs.
CFG_BUILD_DIR = build/${CFG_BUILD_TYPE}/
PREFIX ?= /usr/local
DESTDIR ?=
CFG_OUT_DIR := $(DESTDIR)$(PREFIX)/

# Install directory for python
PYTHON_PREFIX := $(shell /usr/bin/env python3 -c "import site; print(site.getsitepackages()[-1]);")

ifneq ($(PREFIX),/usr/local)
PYTHON_PREFIX := $(PREFIX)
endif

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

#--------------------------------------------------------------------------------
# Define constants with special characters.

# Variable name conventions:
# C.* : raw character string

# New line
override define C.NL :=


endef
override C.EMPTY :=
# Space
override C.SP := ${C.EMPTY} ${C.EMPTY}
# Colon
override C.DC := ${C.EMPTY}:${C.EMPTY}
# Single quote
override C.QUOT := '
# ' # THIS whole line is a comment fixing syntax highlighting in some editors.

#--------------------------------------------------------------------------------
# Define constants for output formatting. Empty when not outputting to a TTY.

# Variable name conventions:
# F.*  : raw control sequence string
# F.x  : enable x
# F.!x : disable x

ifdef MAKE_TERMOUT
override csi := $(shell printf '\x1b[')

# Resets all formatting options
override F.RST := ${csi}0m
# Bold
override F.B   := ${csi}22;1m
override F.!B  := ${csi}22m
# Italic
override F.I   := ${csi}3m
override F.!I  := ${csi}23m
# Dim
override F.D   := ${csi}2m
override F.!D  := ${csi}22m

override undefine csi
else
override F.RST :=
override F.B   :=
override F.!B  :=
override F.I   :=
override F.!I  :=
override F.D   :=
override F.!D  :=
endif
