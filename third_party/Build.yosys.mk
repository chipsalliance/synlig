t  := yosys
ts := $(call GetTargetStructName,${t})

cxx_is_clang := $(findstring clang,$(notdir ${CXX}))

${ts}.src_dir         := ${TOP_DIR}third_party/yosys/
${ts}.mod_dir         := ${TOP_DIR}third_party/yosys_mod/
${ts}.out_install_dir := $(call ToAbsPaths,${OUT_DIR})

${ts}.output_files := \
	${${ts}.src_dir}yosys \
	${${ts}.src_dir}yosys-abc \
	${${ts}.src_dir}yosys-config

${ts}.output_dirs := ${${ts}.src_dir}

${ts}.input_files := $(filter-out ${${ts}.output_files}, \
	$(shell \
		find ${${ts}.src_dir} \
			-path '*/.*' -prune -o \
			-path '${${ts}.src_dir}*/abc' -prune -o \
			-path '${${ts}.src_dir}*/docs' -prune -o \
			-path '${${ts}.src_dir}*/tests' -prune -o \
			-path '${${ts}.src_dir}*/manual' -prune -o \
			-path '${${ts}.src_dir}*/examples' -prune -o \
			-path '${${ts}.src_dir}*/yosys' -o \
			-path '${${ts}.src_dir}*/yosys-*' -o \
			-name '*.o' -o \
			-name '*.d' -o \
			-type f -print \
			| sed "s/ /\\\\ /g" \
	) \
)

${ts}.make_args := \
	PREFIX:=${${ts}.out_install_dir} \
	CONFIG:=$(if cxx_is_clang,clang,gcc) \
	CC:=${CC} \
	CXX:=${CXX} \
	LD:=${CXX} \
	$(if ${LD},LDFLAGS:=$(call ShQuote,${LDFLAGS} ${USE_LD_FLAG}))

cxxflags := ${CXXFLAGS}

ifeq (${BUILD_TYPE},asan)
${ts}.make_args += SANITIZER:=address
ifdef cxx_is_clang
cxxflags += -fsanitize-address-use-after-return=always
endif
endif

ifneq (${BUILD_TYPE},release)
${ts}.make_args += \
	ENABLE_DEBUG:=1 \
	STRIP:=/bin/true
endif

ifdef cxxflags
${ts}.make_args += CPPFLAGS:=$(call ShQuote,${CXXFLAGS})
undefine cxxflags
endif


# Variable evaluation: in recipe, ${var}
define ${ts}.build_command
		cd ${${ts}.src_dir}
		${MAKE} ${${ts}.make_args} --no-print-directory ENABLE_LTO=0
endef

define ${ts}.install_command
		cd ${${ts}.src_dir}
		${MAKE} ${${ts}.make_args} --no-print-directory install
endef

# Variable evaluation: in recipe, ${var}
define ${ts}.src_clean_command
	cd ${${ts}.src_dir}
	targets=(clean)
	[[ -e abc ]] && targets+=(clean-abc) || :
	${MAKE} ${${ts}.make_args} --no-print-directory "$${targets[@]}" || :
endef
