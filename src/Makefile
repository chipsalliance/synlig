# --- build synlig binary --- #

THIS_MK_FILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_MK_DIR := $(patsubst /%/,/%,$(dir $(THIS_MK_FILE)))

REPO_DIR := $(abspath $(THIS_MK_DIR)/..)

YOSYS_SRC := $(REPO_DIR)/third_party/yosys
SYNLIG_SRC := $(REPO_DIR)/src

ifeq ($(SYNLIG_BUILD_TYPE),asan)
BUILD_DIR := $(REPO_DIR)/build/asan/synlig
SURELOG_PKG_DIR := $(REPO_DIR)/build/asan/surelog
else
BUILD_DIR := $(REPO_DIR)/build/release/synlig
SURELOG_PKG_DIR := $(REPO_DIR)/build/release/surelog
endif


# --- set compiler ---#
CONFIG := none
# CONFIG := clang
# CONFIG := gcc

# --- add synlig cxxflags --- #
CXXFLAGS += -DSYNLIG_STANDALONE_BINARY -I $(SYNLIG_SRC)/frontends/*/ -I $(SYNLIG_SRC)/mods/*

# --- add static option --- #
CXXFLAGS += -static

# --- options --- #
ENABLE_COVER := 1
ENABLE_DEBUG := 0
PRETTY_PROGRESS := 1

# --- clang sanitizers --- #
SANITIZER =
# SANITIZER = address
# SANITIZER = memory
# SANITIZER = undefined
# SANITIZER = cfi

# --- check OS --- #
OS := $(shell uname -s)

# --- opt level --- #
OPT_LEVEL := -O3
GCC_LTO :=
CLANG_LTO := -flto=thin

# --- install directory --- #
BINDIR := $(PREFIX)/bin
DATDIR := $(PREFIX)/share/synlig

# --- vpath --- #
VPATH := $(YOSYS_SRC):$(SYNLIG_SRC)

# --- prepare targets --- #
OBJS =
EXTRA_OBJS =
GENFILES =
EXTRA_TARGETS =
TARGETS = $(BUILD_DIR)/synlig $(BUILD_DIR)/synlig-config
OUT_TARGETS = $(BUILD_DIR)/synlig $(BUILD_DIR)/synlig-config
all: top-all

# --- setup linking surelog --- #
define SURELOG_ENV =
export PKG_CONFIG_PATH=$(call ShQuote,${$(call GetTargetStructName,surelog).output_vars.PKG_CONFIG_PATH}$(if ${PKG_CONFIG_PATH},:${PKG_CONFIG_PATH}))
export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:$(SURELOG_PKG_DIR)/install/lib/pkgconfig/:$(SURELOG_PKG_DIR)/build:$(SURELOG_PKG_DIR)/build/third_party/UHDM/
endef

CXXFLAGS += $(shell $(SURELOG_ENV); pkg-config --cflags Surelog)

SURELOG_LDFLAGS = \
    $(if ${LD},${USE_LD_FLAG}) \
    $(shell $(SURELOG_ENV); pkg-config --libs-only-L Surelog) \
    ${LDFLAGS}

SURELOG_LDLIBS = \
    $(shell $(SURELOG_ENV); pkg-config --libs-only-l --libs-only-other Surelog) \
    ${LDLIBS}

CXXSTD ?= c++17
CXXFLAGS := $(CXXFLAGS) -Wall -Wextra -ggdb -I. -I"$(YOSYS_SRC)" -MD -MP -D_YOSYS_ -fPIC -I$(PREFIX)/include -I $(SURELOG_PKG_DIR)/install/include/
LIBS := $(LIBS) -lstdc++ -lm

# --- set up tools --- #
PKG_CONFIG ?= pkg-config
SED ?= sed
BISON ?= bison
STRIP ?= strip
AWK ?= awk

# --- mac/linux --- #
ifeq ($(OS), Darwin)

# homebrew search paths
ifneq ($(shell :; command -v brew),)
BREW_PREFIX := $(shell brew --prefix)/opt
$(info $$BREW_PREFIX is [${BREW_PREFIX}])
CXXFLAGS += -I$(BREW_PREFIX)/readline/include
LINKFLAGS += -L$(BREW_PREFIX)/readline/lib
PKG_CONFIG_PATH := $(BREW_PREFIX)/libffi/lib/pkgconfig:$(PKG_CONFIG_PATH)
PKG_CONFIG_PATH := $(BREW_PREFIX)/tcl-tk/lib/pkgconfig:$(PKG_CONFIG_PATH)
export PATH := $(BREW_PREFIX)/bison/bin:$(BREW_PREFIX)/gettext/bin:$(BREW_PREFIX)/flex/bin:$(PATH)

# macports search paths
else ifneq ($(shell :; command -v port),)
PORT_PREFIX := $(patsubst %/bin/port,%,$(shell :; command -v port))
CXXFLAGS += -I$(PORT_PREFIX)/include
LINKFLAGS += -L$(PORT_PREFIX)/lib
PKG_CONFIG_PATH := $(PORT_PREFIX)/lib/pkgconfig:$(PKG_CONFIG_PATH)
export PATH := $(PORT_PREFIX)/bin:$(PATH)
endif

else
LINKFLAGS += -rdynamic
LIBS += -lrt
endif

# --- detect synlig hash --- #
GIT_REV := $(shell GIT_DIR=$(REPO_DIR)/.git git rev-parse --short=9 HEAD || echo UNKNOWN)
OBJS = kernel/version_$(GIT_REV).o

# --- set abc flags --- #
ABCMKARGS = CC="$(CXX)" CXX="$(CXX)" ABC_USE_LIBSTDCXX=1 ABC_USE_NAMESPACE=abc VERBOSE=$(Q)

# --- detect python --- #
PYTHON_EXECUTABLE := $(shell if python3 -c ""; then echo "python3"; else echo "python"; fi)
PYTHON_CONFIG := $(PYTHON_EXECUTABLE)-config
PYTHON_DESTDIR := $(shell $(PYTHON_EXECUTABLE) -c "import site; print(site.getsitepackages()[-1]);")

# --- gcc/clang --- #
LTOFLAGS := $(GCC_LTO)

ifeq ($(CONFIG),clang)
CXX = clang++
CXXFLAGS += -std=$(CXXSTD) $(OPT_LEVEL)
ABCMKARGS += ARCHFLAGS="-DABC_USE_STDINT_H"
LTOFLAGS := $(CLANG_LTO)
ifneq ($(SANITIZER),)
$(info [Clang Sanitizer] $(SANITIZER))
CXXFLAGS += -g -O1 -fno-omit-frame-pointer -fno-optimize-sibling-calls -fsanitize=$(SANITIZER)
LINKFLAGS += -g -fsanitize=$(SANITIZER)
ifneq ($(findstring address,$(SANITIZER)),)
ENABLE_COVER := 0
endif
ifneq ($(findstring memory,$(SANITIZER)),)
CXXFLAGS += -fPIE -fsanitize-memory-track-origins
LINKFLAGS += -fPIE -fsanitize-memory-track-origins
endif
ifneq ($(findstring cfi,$(SANITIZER)),)
CXXFLAGS += -flto
LINKFLAGS += -flto
LTOFLAGS =
endif
endif

else ifeq ($(CONFIG),gcc)
CXX = g++
CXXFLAGS += -std=$(CXXSTD) $(OPT_LEVEL)
ABCMKARGS += ARCHFLAGS="-DABC_USE_STDINT_H"

else ifeq ($(CONFIG),none)
CXXFLAGS += -std=$(CXXSTD) $(OPT_LEVEL)
ABCMKARGS += ARCHFLAGS="-DABC_USE_STDINT_H"
LTOFLAGS =

else
$(error Invalid CONFIG setting '$(CONFIG)'. Valid values: clang, gcc, none)
endif

# --- setup flags and libs --- #
CXXFLAGS += -DYOSYS_ENABLE_READLINE
CXXFLAGS += $(shell PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) $(PKG_CONFIG) --silence-errors --cflags libffi) -DYOSYS_ENABLE_PLUGINS
CXXFLAGS += -DYOSYS_ENABLE_GLOB
CXXFLAGS += -DYOSYS_ENABLE_ZLIB
LIBS += $(shell PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) $(PKG_CONFIG) --silence-errors --libs libffi || echo -lffi)
LIBS += -lreadline
LIBS += -lz

# --- setup tcl --- #
TCL_VERSION ?= tcl$(shell bash -c "tclsh <(echo 'puts [info tclversion]')")
TCL_INCLUDE ?= /usr/include/$(TCL_VERSION)
TCL_LIBS ?= -l$(TCL_VERSION)
CXXFLAGS += $(shell PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) $(PKG_CONFIG) --silence-errors --cflags tcl || echo -I$(TCL_INCLUDE)) -DYOSYS_ENABLE_TCL
LIBS += $(shell PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) $(PKG_CONFIG) --silence-errors --libs tcl || echo $(TCL_LIBS))

# --- debug --- #
ifeq ($(ENABLE_DEBUG),1)
CXXFLAGS := -Og -DDEBUG $(filter-out $(OPT_LEVEL),$(CXXFLAGS))
endif

# --- link abc --- #
CXXFLAGS += -DYOSYS_ENABLE_ABC
CXXFLAGS += -DYOSYS_LINK_ABC
LIBS += -lpthread

# --- setup cover --- #
ifeq ($(ENABLE_COVER),1)
CXXFLAGS += -DYOSYS_ENABLE_COVER
endif

# --- setup progress printing --- #
ifeq ($(PRETTY_PROGRESS),1)
P_STATUS = 0
P_OFFSET = 0
P_UPDATE = $(eval P_STATUS=$(shell echo $(YOSYS_OBJS) $(SYNLIG_OBJS) | $(AWK) 'BEGIN { RS = " "; I = $(P_STATUS)+0; } $$1 == "$@" && NR > I { I = NR; } END { print I; }'))
P_SHOW = [$(shell $(AWK) "BEGIN { N=$(words $(YOSYS_OBJS) $(SYNLIG_OBJS)); printf \"%3d\", $(P_OFFSET)+80*$(P_STATUS)/N; exit; }")%]
P = @echo "$(if $(findstring $@,$(TARGETS) $(EXTRA_TARGETS)),$(eval P_OFFSET = 5))$(call P_UPDATE)$(call P_SHOW) Building $(shell echo $@ | $(SED) -s "s#$(BUILD_DIR)/##g")";
Q = @
S = -s
endif

# --- this variables are used in */Makefile.inc --- #
ENABLE_ABC := 1
ENABLE_VERIFIC := 0
ENABLE_VERIFIC_VHDL := 1
ENABLE_ZLIB := 1
DISABLE_SPAWN := 0
SMALL = 0

# --- prepare defines for adding include files --- #
define add_share_file
EXTRA_TARGETS += $(subst //,/,$(1)/$(notdir $(2)))
$(subst //,/,$(BUILD_DIR)/$(1)/$(notdir $(2))): $(2)
	$$(P) mkdir -p $(1)
	$$(Q) cp "$(YOSYS_SRC)"/$(2) $(subst //,/,$(1)/$(notdir $(2)))
endef

define add_gen_share_file
EXTRA_TARGETS += $(subst //,/,$(1)/$(notdir $(2)))
$(subst //,/,$(BUILD_DIR)/$(1)/$(notdir $(2))): $(BUILD_DIR)/$(2)
	$$(P) mkdir -p $(1)
	$$(Q) cp $(2) $(subst //,/,$(1)/$(notdir $(2)))
endef

define add_include_file
$(eval $(call add_share_file,$(dir share/include/$(1)),$(1)))
endef

define add_extra_objs
EXTRA_OBJS += $(1)
.SECONDARY: $(1)
endef

# --- add include files --- #
$(eval $(call add_include_file,kernel/binding.h))
$(eval $(call add_include_file,kernel/bitpattern.h))
$(eval $(call add_include_file,kernel/cellaigs.h))
$(eval $(call add_include_file,kernel/celledges.h))
$(eval $(call add_include_file,kernel/celltypes.h))
$(eval $(call add_include_file,kernel/consteval.h))
$(eval $(call add_include_file,kernel/constids.inc))
$(eval $(call add_include_file,kernel/cost.h))
$(eval $(call add_include_file,kernel/ff.h))
$(eval $(call add_include_file,kernel/ffinit.h))
$(eval $(call add_include_file,kernel/ffmerge.h))
$(eval $(call add_include_file,kernel/fmt.h))
$(eval $(call add_include_file,kernel/fstdata.h))
$(eval $(call add_include_file,kernel/hashlib.h))
$(eval $(call add_include_file,kernel/json.h))
$(eval $(call add_include_file,kernel/log.h))
$(eval $(call add_include_file,kernel/macc.h))
$(eval $(call add_include_file,kernel/modtools.h))
$(eval $(call add_include_file,kernel/mem.h))
$(eval $(call add_include_file,kernel/qcsat.h))
$(eval $(call add_include_file,kernel/register.h))
$(eval $(call add_include_file,kernel/rtlil.h))
$(eval $(call add_include_file,kernel/satgen.h))
$(eval $(call add_include_file,kernel/scopeinfo.h))
$(eval $(call add_include_file,kernel/sigtools.h))
$(eval $(call add_include_file,kernel/timinginfo.h))
$(eval $(call add_include_file,kernel/utils.h))
$(eval $(call add_include_file,kernel/yosys.h))
$(eval $(call add_include_file,kernel/yosys_common.h))
$(eval $(call add_include_file,kernel/yw.h))
$(eval $(call add_include_file,libs/ezsat/ezsat.h))
$(eval $(call add_include_file,libs/ezsat/ezminisat.h))
$(eval $(call add_include_file,libs/fst/fstapi.h))
$(eval $(call add_include_file,libs/sha1/sha1.h))
$(eval $(call add_include_file,libs/json11/json11.hpp))
$(eval $(call add_include_file,passes/fsm/fsmdata.h))
$(eval $(call add_include_file,frontends/ast/ast.h))
$(eval $(call add_include_file,frontends/ast/ast_binding.h))
$(eval $(call add_include_file,frontends/blif/blifparse.h))
$(eval $(call add_include_file,backends/rtlil/rtlil_backend.h))

# --- add obj files --- #
OBJS += kernel/register.o kernel/rtlil.o kernel/log.o kernel/calc.o kernel/yosys.o
OBJS += kernel/binding.o
OBJS += kernel/cellaigs.o kernel/celledges.o kernel/cost.o kernel/satgen.o kernel/scopeinfo.o kernel/qcsat.o kernel/mem.o kernel/ffmerge.o kernel/ff.o kernel/yw.o kernel/json.o kernel/fmt.o
OBJS += kernel/fstdata.o

OBJS += libs/bigint/BigIntegerAlgorithms.o libs/bigint/BigInteger.o libs/bigint/BigIntegerUtils.o
OBJS += libs/bigint/BigUnsigned.o libs/bigint/BigUnsignedInABase.o

OBJS += libs/sha1/sha1.o

OBJS += libs/json11/json11.o

OBJS += libs/ezsat/ezsat.o
OBJS += libs/ezsat/ezminisat.o

OBJS += libs/minisat/Options.o
OBJS += libs/minisat/SimpSolver.o
OBJS += libs/minisat/Solver.o
OBJS += libs/minisat/System.o

OBJS += libs/fst/fstapi.o
OBJS += libs/fst/fastlz.o
OBJS += libs/fst/lz4.o

OBJS += libs/subcircuit/subcircuit.o

include $(YOSYS_SRC)/frontends/*/Makefile.inc
include $(YOSYS_SRC)/passes/*/Makefile.inc
include $(YOSYS_SRC)/techlibs/*/Makefile.inc

# include $(YOSYS_SRC)/backends/*/Makefile.inc exclude edif pass because of collision with pass in yosys_mod
include $(YOSYS_SRC)/backends/smv/Makefile.inc
include $(YOSYS_SRC)/backends/cxxrtl/Makefile.inc
include $(YOSYS_SRC)/backends/simplec/Makefile.inc
include $(YOSYS_SRC)/backends/rtlil/Makefile.inc
include $(YOSYS_SRC)/backends/blif/Makefile.inc
include $(YOSYS_SRC)/backends/btor/Makefile.inc
include $(YOSYS_SRC)/backends/jny/Makefile.inc
include $(YOSYS_SRC)/backends/smt2/Makefile.inc
include $(YOSYS_SRC)/backends/verilog/Makefile.inc
include $(YOSYS_SRC)/backends/firrtl/Makefile.inc
include $(YOSYS_SRC)/backends/table/Makefile.inc
include $(YOSYS_SRC)/backends/json/Makefile.inc
include $(YOSYS_SRC)/backends/aiger/Makefile.inc
include $(YOSYS_SRC)/backends/intersynth/Makefile.inc
include $(YOSYS_SRC)/backends/spice/Makefile.inc

SYNLIG_OBJS += main.o
SYNLIG_OBJS += yosys-libabc.a

include $(SYNLIG_SRC)/frontends/*/Makefile.inc
include $(SYNLIG_SRC)/mods/*/Makefile.inc

# --- prefix objects --- #

YOSYS_OBJS = $(addprefix $(BUILD_DIR)/, $(OBJS))
SYNLIG_OBJS := $(addprefix $(BUILD_DIR)/, $(SYNLIG_OBJS))
GENFILES := $(addprefix $(BUILD_DIR)/, $(GENFILES))
EXTRA_OBJS := $(addprefix $(BUILD_DIR)/, $(EXTRA_OBJS))
EXTRA_TARGETS := $(addprefix $(BUILD_DIR)/, $(EXTRA_TARGETS))

# --- unexport CXXFLAGS --- #

# prevent the CXXFLAGS set by this Makefile from reaching abc/Makefile,
# especially the -MD flag which will break the build when CXX is clang
unexport CXXFLAGS

# --- include yosys targets and dependencies --- #
include $(REPO_DIR)/src/Makefile.inc

# --- make targets --- #
top-all: $(TARGETS) $(EXTRA_TARGETS)
	@echo ""
	@echo "  Build successful."
	@echo ""

.PHONY: compile-only
compile-only: $(YOSYS_OBJS) $(SYNLIG_OBJS) $(GENFILES) $(EXTRA_TARGETS)
	@echo ""
	@echo "  Compile successful."
	@echo ""

$(BUILD_DIR)/kernel/log.o: CXXFLAGS += -DYOSYS_SRC='"$(YOSYS_SRC)"'
$(BUILD_DIR)/kernel/yosys.o: CXXFLAGS += -DYOSYS_DATDIR='"$(DATDIR)"' -DYOSYS_PROGRAM_PREFIX='""'

$(BUILD_DIR)/synlig: $(YOSYS_OBJS) $(SYNLIG_OBJS)
	$(CXX) -o synlig $(LINKFLAGS) $(YOSYS_OBJS) $(SYNLIG_OBJS) $(LIBS) $(SURELOG_LDFLAGS) $(SURELOG_LDLIBS)

$(BUILD_DIR)/synlig-config: misc/yosys-config.in $(YOSYS_SRC)/Makefile
	$(P) $(SED) -e 's#@CXX@#$(strip $(CXX))#;' -e 's#@CXXFLAGS@#$(strip $(CXXFLAGS))#;' -e 's#-static##;' \
			-e 's#@LINKFLAGS@#$(strip $(LINKFLAGS))#;' -e 's#@LIBS@#$(strip $(LIBS))#;' \
			-e 's#@BINDIR@#$(strip $(BINDIR))#;' -e 's#@DATDIR@#$(strip $(DATDIR))#;' < $< > synlig-config
	$(Q) chmod +x synlig-config

$(BUILD_DIR)/frontends/systemverilog/%.o: frontends/systemverilog/%.cc
	$(Q) mkdir -p $(dir $@)
	$(P) $(CXX) -o $@ -c $(CPPFLAGS) $(CXXFLAGS) -Wno-unused-parameter -I ./ $<

$(BUILD_DIR)/%.o: %.cc
	$(Q) mkdir -p $(dir $@)
	$(P) $(CXX) -o $@ -c $(CPPFLAGS) $(CXXFLAGS) -I ./ $<

$(BUILD_DIR)/%.pyh: %.h
	$(Q) mkdir -p $(dir $@)
	$(P) cat $< | grep -E -v "#[ ]*(include|error)" | $(CXX) $(CXXFLAGS) -x c++ -o $@ -E -P -

$(BUILD_DIR)/%.o: %.cpp
	$(Q) mkdir -p $(dir $@)
	$(P) $(CXX) -o $@ -c $(CPPFLAGS) $(CXXFLAGS) $<

VERSION_STR := Synlig (git sha1 $(GIT_REV), $(notdir $(CXX)) $(shell \
		$(CXX) --version | tr ' ()' '\n' | grep '^[0-9]' | head -n1) $(filter -f% -m% -O% -DNDEBUG,$(CXXFLAGS)))

$(BUILD_DIR)/kernel/version_$(GIT_REV).cc: $(YOSYS_SRC)/Makefile
	$(P) rm -f kernel/version_*.o kernel/version_*.d kernel/version_*.cc
	$(Q) mkdir -p kernel && echo "namespace Yosys { extern const char *yosys_version_str; const char *yosys_version_str=\"$(VERSION_STR)\"; }" > kernel/version_$(GIT_REV).cc

.PHONY: check-git-abc

check-git-abc:
	@if [ ! -d "$(YOSYS_SRC)/abc" ]; then \
		echo "Error: The 'abc' directory does not exist."; \
		echo "Initialize the submodule: Run 'git submodule update --init --recursive third_party/yosys' to set up 'abc' as a submodule."; \
		exit 1; \
	elif git -C "$(YOSYS_SRC)" submodule status abc 2>/dev/null | grep -q '^ '; then \
		exit 0; \
	else \
		echo "Error: 'third_party/yosys/abc' directory exists but is not configured as a git submodule."; \
		echo "Initialize the submodule: Run 'git submodule update --init --recursive --force third_party/yosys' to set up 'abc' as a submodule."; \
		exit 1; \
	fi

abc/libabc.a: | check-git-abc
	$(P)
	$(Q) mkdir -p abc && $(MAKE) -C abc -f "$(realpath $(YOSYS_SRC)/abc/Makefile)" ABCSRC="$(realpath $(YOSYS_SRC)/abc/)" $(S) $(ABCMKARGS) $(if $(filter %.a,$@),PROG="abc",PROG="abc") MSG_PREFIX="$(eval P_OFFSET = 10)$(call P_SHOW)$(eval P_OFFSET = 15) ABC: " $(if $(filter %.a,$@),libabc.a)

$(BUILD_DIR)/yosys-libabc.a: abc/libabc.a
	$(P) cp $< $(BUILD_DIR)/yosys-libabc.a

install: $(TARGETS) $(EXTRA_TARGETS)
	mkdir -p $(DESTDIR)$(BINDIR)
	cp $(OUT_TARGETS) $(DESTDIR)$(BINDIR)
	$(STRIP) -S $(DESTDIR)$(BINDIR)/synlig
	mkdir -p $(DESTDIR)$(DATDIR)
	cp -r $(BUILD_DIR)/share/. $(DESTDIR)$(DATDIR)/.

uninstall:
	rm -vf $(addprefix $(DESTDIR)$(BINDIR)/,$(notdir $(TARGETS)))
	rm -rvf $(DESTDIR)$(DATDIR)

-include libs/*/*.d
-include frontends/*/*.d
-include passes/*/*.d
-include backends/*/*.d
-include kernel/*.d
-include techlibs/*/*.d

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all top-all abc install clean
