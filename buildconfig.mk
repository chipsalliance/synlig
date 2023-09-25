# Default configuration for project Makefile.
#
# If you wish to modify configuration in this file just for your local builds,
# it is recommended to create `buildconfig.user.mk` file and put your overrides
# there.
#
# You can also set configuration variable through make command line arguments.
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# One of: release, debug, asan
CFG_BUILD_TYPE := release

# Base directory for all build outputs.
CFG_OUT_DIR = out/${CFG_BUILD_TYPE}/

# Basic build tools
CC       ?= cc
CXX      ?= c++
LD       ?=
CFLAGS   ?=
CXXFLAGS ?=
LDFLAGS  ?=
LDLIBS   ?=

#───────────────────────────────────────────────────────────────────────────────
-include ${TOP_DIR}buildconfig.user.mk
