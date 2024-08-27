t  := yosys-tools
ts := $(call GetTargetStructName,${t})

cxx_is_clang := $(findstring clang,$(notdir ${CXX}))

${ts}.src_dir         := ${TOP_DIR}third_party/yosys/
${ts}.mod_dir         := ${TOP_DIR}third_party/yosys_mod/
${ts}.out_install_dir := $(call ToAbsPaths,${OUT_DIR})

${ts}.output_files := yosys-abc yosys-smtbmc yosys-filterlib

${ts}.make_args := \
	PREFIX:=${${ts}.out_install_dir} \
	CONFIG:=$(if cxx_is_clang,clang,gcc) \
	CC:=${CC} \
	CXX:=${CXX} \
	LD:=${CXX} \
	$(if ${LD},LDFLAGS:=$(call ShQuote,${LDFLAGS} ${USE_LD_FLAG}))

cxxflags := ${CXXFLAGS}

define ${ts}.build_command
	${MAKE} -C ${${ts}.src_dir} ${${ts}.output_files} ${${ts}.make_args}
endef

define ${ts}.install_command
	cp ${${ts}.src_dir}/yosys-abc ${OUT_DIR}/bin
	cp ${${ts}.src_dir}/yosys-smtbmc ${OUT_DIR}/bin
	cp ${${ts}.src_dir}/yosys-filterlib ${OUT_DIR}/bin
endef
