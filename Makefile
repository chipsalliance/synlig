#!/usr/bin/env -S sh -c '/usr/bin/env make -j$(nproc) -rR -Oline -f "$0" "$@"'
#───────────────────────────────────────────────────────────────────────────────
# Setup make itself.

.ONESHELL:
SHELL := bash
override .SHELLFLAGS := -e -u -o pipefail -O nullglob -O extglob -O globstar -c

# Unset all default build- and recipe-related variables.
# Since this is exactly what `-R` make flag does don't bother if it is set.
override letter_makeflags := $(filter-out -%,$(firstword ${MAKEFLAGS}))
ifeq ($(findstring R,${l.letter_makeflags}),)
$(foreach v,$(filter-out MAKE% GNUMAKE% .%,$(.VARIABLES)), \
    $(if $(filter default,$(origin ${v})), \
        $(eval override undefine ${v}) \
    ) \
)
SUFFIXES :=
endif
override undefine letter_makeflags

#───────────────────────────────────────────────────────────────────────────────
# Load config.

override TOP_DIR := $(dir $(abspath $(lastword ${MAKEFILE_LIST})))

include ${TOP_DIR}buildconfig.mk

#───────────────────────────────────────────────────────────────────────────────
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

#───────────────────────────────────────────────────────────────────────────────
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

#───────────────────────────────────────────────────────────────────────────────

# Convert path from relative to absolute (assuming `${2}` or `${TOP_DIR}` as
# the base).
#
# ${1}: List of paths.
# ${2}: Base directory for relative paths. Optional, `${TOP_DIR}` if missing.
ToAbsPaths = $(strip $(foreach p,$(strip ${1}),\
	$(patsubst //,/,$(abspath $(or \
		$(filter /%,${p}), \
		$(or $(strip ${2}),${TOP_DIR})${p} \
	))$(if $(filter %/ %/.. %/.,${p}),/))\
))


# Convert path from relative to absolute (assuming `${2}` or `${TOP_DIR}` as
# the base) and add trailing `/` if not already present.
#
# ${1}: List of directory paths.
# ${2}: Base directory for relative paths. Optional, `${TOP_DIR}` if missing.
ToAbsDirPaths = $(call ToAbsPaths,$(addsuffix /,$(strip ${1})),${2})


ShQuote = '$(subst ${C.QUOT},'\'',$(strip ${1}))'


ShQuoteList = $(foreach v,$(strip ${1}),$(call ShQuote,$v))

#───────────────────────────────────────────────────────────────────────────────
# Make sure internal variables are not overridden through command line.
# Special variables are those with at least one lowercase letter in the name.
# We could use `override` everywhere, but that's quite verbose.

override command_line_illegal_vars := $(strip $(foreach v,${.VARIABLES},\
	$(if $(filter command_line,$(subst ${C.SP},_,$(origin ${v}))),${v})\
))
override command_line_illegal_vars := $(shell \
	for f in $(call ShQuoteList,${command_line_illegal_vars}); do \
		[[ "$$f" =~ ^[A-Z][A-Z0-9_]*$$ ]] || echo "$$f"; \
	done;\
)

ifdef command_line_illegal_vars
override define error_message :=
ERROR${C.DC} Overridding internal variables through make${C.QUOT}s command line is prohibited.
Overriden variables${C.DC}
$(subst ${C.NL}${C.SP},${C.NL},$(foreach v,${command_line_illegal_vars},- ${v} $(if $(filter simple,$(flavor ${v})),:=,=) ${${v}}${C.NL}))
..
endef
$(error ${error_message})
endif
override undefine command_line_illegal_vars

#───────────────────────────────────────────────────────────────────────────────
# Validate configuration variable values and assign them to variables without
# `CFG_` prefix used internally.

override ALL_ALLOWED_BUILD_TYPES := release debug asan
$(if $(filter-out 1,$(words $(filter ${ALL_ALLOWED_BUILD_TYPES},${CFG_BUILD_TYPE}))),\
	$(error CFG_BUILD_TYPE: invalid value (${CFG_BUILD_TYPE}). Must be one of: ${ALL_ALLOWED_BUILD_TYPES})\
)
override BUILD_TYPE := ${CFG_BUILD_TYPE}
_cfg_build_type := $(value CFG_BUILD_TYPE)
_cfg_build_type_eq := $(if $(filter recursive,$(flavor CFG_BUILD_TYPE)),=,:=)

override BUILD_DIR := $(call ToAbsDirPaths,${CFG_BUILD_DIR})
# Resolve BUILD_DIR with CFG_BUILD_TYPE set to space to get common path prefix for
# each build type.
override CFG_BUILD_TYPE = ${C.SP}
override build_dir_common_parent := $(call ToAbsDirPaths,$(dir $(firstword ${CFG_BUILD_DIR})))
ifeq (${build_dir_common_parent},${BUILD_DIR})
# BUILD_DIR does not depend on CFG_BUILD_TYPE. Do not create "current" symlink.
override undefine build_dir_current_symlink
else
# Resolve BUILD_DIR with CFG_BUILD_TYPE set to "current" and remove common prefix
# to get "common" symlink path
override CFG_BUILD_TYPE = current
override build_dir_current_symlink := $(patsubst %/,%,$(call ToAbsDirPaths,${CFG_BUILD_DIR}))
# Calculate relative symlink target
override build_dir_current_symlink_target := $(firstword $(subst /,${C.SP},$(patsubst ${build_dir_common_parent}%,%,${BUILD_DIR})))
endif
override undefine CFG_BUILD_TYPE
$(eval CFG_BUILD_TYPE ${_cfg_build_type_eq} ${_cfg_build_type})

override OUT_DIR := $(call ToAbsDirPaths,${CFG_OUT_DIR})
# Resolve OUT_DIR with CFG_BUILD_TYPE set to space to get common path prefix for
# each build type.
override CFG_BUILD_TYPE = ${C.SP}
override out_dir_common_parent := $(call ToAbsDirPaths,$(dir $(firstword ${CFG_OUT_DIR})))
ifeq (${out_dir_common_parent},${OUT_DIR})
# OUT_DIR does not depend on CFG_BUILD_TYPE. Do not create "current" symlink.
override undefine out_dir_current_symlink
else
# Resolve OUT_DIR with CFG_BUILD_TYPE set to "current" and remove common prefix
# to get "common" symlink path
override CFG_BUILD_TYPE = current
override out_dir_current_symlink := $(patsubst %/,%,$(call ToAbsDirPaths,${CFG_OUT_DIR}))
# Calculate relative symlink target
override out_dir_current_symlink_target := $(firstword $(subst /,${C.SP},$(patsubst ${out_dir_common_parent}%,%,${OUT_DIR})))
endif
override undefine CFG_BUILD_TYPE
$(eval CFG_BUILD_TYPE ${_cfg_build_type_eq} ${_cfg_build_type})

override undefine _cfg_build_type
override undefine _cfg_build_type_eq


# Set derived constants

override BUILD_DIR := ${CFG_BUILD_DIR}
override OUT_DIR := ${CFG_OUT_DIR}

GetTargetBuildDir = $(call ToAbsPaths,${BUILD_DIR}${1}/)


# Export non-empty tool-related variables

tool_related_variables := CC CXX LD CPPFLAGS CXXFLAGS LDFLAGS LDLIBS MAKE
$(foreach v,${tool_related_variables},$(if ${${v}},$(eval export ${v})))

#───────────────────────────────────────────────────────────────────────────────
# Print table with date and configuration.

# Skip this for informational targets.
ifneq ($(filter-out list help,${MAKECMDGOALS}),)
variables_to_dump := \
	CFG_BUILD_TYPE \
	CFG_BUILD_DIR \
	CFG_OUT_DIR \
	CC \
	CXX \
	LD \
	CPPFLAGS \
	CXXFLAGS \
	LDFLAGS \
	LDLIBS

# Measuring variable name + ":"
longest_variable_len := $(shell printf '%s:\n' $(call ShQuoteList,${variables_to_dump}) | wc -L)

$(info ▖)
$(info ▌ $(shell printf '%-${longest_variable_len}s\t%s' 'Date:' "$$(date --iso-8601=seconds)"))
$(info ▌)
$(foreach v,${variables_to_dump},\
	$(info ▌ $(shell \
		printf '%-${longest_variable_len}s\t%s' $(call ShQuote,${v}:) $(call ShQuote,${${v}})\
	))\
)
$(info ▘)

undefine longest_variable_len
undefine variables_to_dump
endif

#───────────────────────────────────────────────────────────────────────────────
# Update "current" symlink, if needed.

# Skip this for targets that do not build anything.
ifneq ($(filter-out list help,${MAKECMDGOALS}),)
ifdef build_dir_current_symlink
$(shell mkdir -p ${build_dir_common_parent})
$(shell ln -fs -T ${build_dir_current_symlink_target} ${build_dir_current_symlink})
endif
ifdef out_dir_current_symlink
$(shell mkdir -p ${out_dir_common_parent})
$(shell ln -fs -T ${out_dir_current_symlink_target} ${out_dir_current_symlink})
endif
endif

#───────────────────────────────────────────────────────────────────────────────
# Check whether build configuration changed, and warn if so.

# Skip this for targets that do not build anything.
ifneq ($(filter-out list clean help,${MAKECMDGOALS}),)
define buildconfig_state_file_content :=
CFG_BUILD_TYPE:=${BUILD_TYPE}
CC:=${CC}
CXX:=${CXX}
LD:=${LD}
CPPFLAGS:=${CPPFLAGS}
CXXFLAGS:=${CXXFLAGS}
LDFLAGS:=${LDFLAGS}
LDLIBS:=${LDLIBS}
endef

buildconfig_state_file := $(wildcard ${BUILD_DIR}buildconfig)
ifdef buildconfig_state_file
$(file >${buildconfig_state_file}.new,${buildconfig_state_file_content}${C.NL})
config_changed := $(shell cmp ${buildconfig_state_file} ${buildconfig_state_file}.new || echo 1)
ifdef config_changed
$(shell mv ${buildconfig_state_file} ${buildconfig_state_file}.old)
$(shell cd ${BUILD_DIR};  diff -tu buildconfig.old buildconfig.new > ${BUILD_DIR}.buildconfig.diff)
define warning_message :=
WARNING${C.DC} Build configuration for the build directory changed!
It is recommended to interrupt this build and clean the directory with:

	${MAKE} CFG_BUILD_DIR:=${BUILD_DIR} clean

Configuration diff:
┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄
$(file <${BUILD_DIR}.buildconfig.diff)
┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄

This message won't be shown again. The original buildconfig file has been moved to:
${buildconfig_state_file}.old
endef
$(shell rm ${BUILD_DIR}.buildconfig.diff)
$(warning ${warning_message})
undefine warning_message
endif
$(shell cp ${buildconfig_state_file}.new ${buildconfig_state_file})
undefine config_changed
else
# TODO(mglb): convert it to a target
buildconfig_state_file := ${BUILD_DIR}buildconfig
$(shell mkdir -p ${BUILD_DIR})
$(file >${buildconfig_state_file},${buildconfig_state_file_content}${C.NL})
endif
undefine buildconfig_state_file_content
undefine buildconfig_state_file
endif

#───────────────────────────────────────────────────────────────────────────────
# Set the linker flag
#
ifneq (${LD},ld)
	USE_LD_FLAG = -fuse-ld=${LD}
endif

#───────────────────────────────────────────────────────────────────────────────
# Include module-makefiles

GetTargetStructName = target[${1}]

makefiles_to_include := \
	third_party/Build.*.mk \
	frontends/*/Build.mk \
	tests/*/Build.mk \
	lib/*/Build.mk

$(foreach THIS_BUILD_MK,$(wildcard $(call ToAbsPaths,${makefiles_to_include})),\
	$(eval include ${THIS_BUILD_MK})\
)

#───────────────────────────────────────────────────────────────────────────────
# Create common targets

_GetTargetsList = $(patsubst $(call GetTargetStructName,%).${1},%,$(filter $(call GetTargetStructName,%).${1},${.VARIABLES}))
GetTargetsList = $(call _GetTargetsList,$(or $(strip ${1}),output_files))


.PHONY: list
list :
	@:
	printf '${F.B}Common targets${F.!B}\n\n'
	printf '    %s\n' \
			'list ${F.D}|${F.!D} help' \
			'build' \
			'install' \
			'clean' \
			;
	echo
	printf '${F.B}Common component targets${F.!B} (`${F.I}component${F.!I}` is a component name placeholder)\n\n'
	printf '    %s\n' \
			'build@${F.I}component${F.!I}' \
			'install@${F.I}component${F.!I} ${F.D}|${F.!D} @${F.I}component${F.!I}' \
			'clean@${F.I}component${F.!I}' \
			;
	echo
	printf '${F.B}Component sources cleanup targets${F.!B}\n\n'
	printf '    %s\n' $(call ShQuoteList,$(addprefix srcclean@,$(call GetTargetsList,src_clean_command)))
	echo
	printf '${F.B}Available components${F.!B}\n\n'
	printf '    %s\n' $(call ShQuoteList,${GetTargetsList})
	echo


.PHONY: help
help : list


.PHONY: build
build : $(foreach t,${GetTargetsList}, @${t})


.PHONY: install
install : $(foreach t,${GetTargetsList}, install@${t})


.PHONY: clean
clean : $(foreach t,${GetTargetsList},$(if ${$(call GetTargetStructName,${t}).src_clean_command},srcclean@${t}))
	@:
	if [[ -e ${BUILD_DIR}buildconfig ]]; then
		rm -rf ${BUILD_DIR} ${OUT_DIR}
	fi

#───────────────────────────────────────────────────────────────────────────────
# Create component targets

# Skip this for informational targets.
ifneq ($(filter-out list help,${MAKECMDGOALS}),)

$(sort $(foreach v,$(filter $(call GetTargetStructName,%).output_dirs,${.VARIABLES}),${${v}})) :
	@mkdir -p $@


override define _single_target_rules

.PHONY: @${t}
@${t} : install@${t}


.PHONY: build@${t}
build@${t} : ${${ts}.output_files}


.PHONY: install@${t}
install@${t} : private t := ${t}
install@${t} : private ts := ${ts}
install@${t} : build@${t}
ifdef ${ts}.install_command
	+@${${ts}.install_command}
else
	$(foreach srcdst,${${ts}.install_copy_list},\
		$(foreach src,$(word 1,$(subst :,${C.SP},${srcdst})),\
			$(foreach dst,$(call ToAbsPaths,${OUT_DIR}$(word 2,$(subst :,${C.SP},${srcdst}))),\
				$(if $(filter %/,${dst}),mkdir -p ${dst}${C.NL})\
				cp -ar ${src} ${dst}${C.NL}\
			)\
		)\
	)
endif


.PHONY: clean@${t}
clean@${t} : private t := ${t}
clean@${t} :
	rm -rf $(call ShQuote,$(call GetTargetBuildDir,${t}))


ifdef ${ts}.rules
${${ts}.output_files} &: private t := ${t}
${${ts}.output_files} &: private ts := ${ts}
$(eval $(value ${ts}.rules))
endif


ifdef ${ts}.build_command
${${ts}.output_files} &: private t := ${t}
${${ts}.output_files} &: private ts := ${ts}
${${ts}.output_files} &: ${${ts}.input_files} | ${${ts}.output_dirs}
	+@${${ts}.build_command}
endif


ifdef ${ts}.src_clean_command
.PHONY: srcclean@${t}
srcclean@${t} : private t := ${t}
srcclean@${t} : private ts := ${ts}
srcclean@${t} :
	+${${ts}.src_clean_command}

clean@${t} : srcclean@${t}
endif

endef
$(foreach t,${GetTargetsList},$(foreach ts,$(call GetTargetStructName,${t}),$(eval $(value _single_target_rules))))

endif
