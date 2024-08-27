t       := systemverilog-plugin
ts      := $(call GetTargetStructName,${t})
out_dir := $(call GetTargetBuildDir,${t})

cxx_is_clang := $(findstring clang,$(notdir ${CXX}))

${ts}.src_dir       := $(call ToAbsDirPaths,$(dir ${THIS_BUILD_MK}))
${ts}.out_build_dir := ${out_dir}

${ts}.sources := \
	${${ts}.src_dir}compat_symbols.cc \
	${${ts}.src_dir}uhdm_ast.cc \
	${${ts}.src_dir}uhdm_ast_frontend.cc \
	${${ts}.src_dir}uhdm_common_frontend.cc \
	${${ts}.src_dir}uhdm_surelog_ast_frontend.cc \
	${$(call GetTargetStructName,yosys).mod_dir}synlig_const2ast.cc \
	${$(call GetTargetStructName,yosys).mod_dir}synlig_edif.cc \
	${$(call GetTargetStructName,yosys).mod_dir}synlig_simplify.cc

define ${ts}.env =
export PKG_CONFIG_PATH=$(call ShQuote,${$(call GetTargetStructName,surelog).output_vars.PKG_CONFIG_PATH}$(if ${PKG_CONFIG_PATH},:${PKG_CONFIG_PATH}))
endef

ifeq (${BUILD_TYPE},release)
build_type_cxxflags = -O3
else
build_type_cxxflags = -g -Og
ifeq (${BUILD_TYPE},asan)
ifndef cxx_is_clang
$(error ERROR: Address sanitizer is currently only supported with clang)
endif
build_type_cxxflags += -fsanitize=address -mllvm -asan-use-private-alias=1
build_type_ldflags = -fsanitize=address
endif
endif

${ts}.cxxflags = \
	-I${$(call GetTargetStructName,yosys).src_dir} \
	-I${$(call GetTargetStructName,yosys).mod_dir} \
	-D_YOSYS_ \
	-DYOSYS_ENABLE_PLUGINS \
	$(shell ${${ts}.env}; pkg-config --cflags Surelog) \
	${build_type_cxxflags} \
	-Wall \
	-W \
	-Wextra \
	-Wno-deprecated-declarations \
	-Wno-unused-parameter \
	${CXXFLAGS} \
	-std=c++17 \
	-fPIC

${ts}.ldflags = \
	$(if ${LD},${USE_LD_FLAG}) \
	$(shell ${${ts}.env}; pkg-config --libs-only-L Surelog) \
	${build_type_ldflags} \
	${LDFLAGS}

${ts}.ldlibs = \
	$(shell ${${ts}.env}; pkg-config --libs-only-l --libs-only-other Surelog) \
	${LDLIBS}

${ts}.out_lib_file := ${${ts}.out_build_dir}systemverilog.so

${ts}.MapSourceToObjectFile     = $(patsubst %.cc,${${ts}.out_build_dir}%.o, $(notdir $(strip ${1})))
${ts}.MapSourceToDependencyFile = $(patsubst %.cc,${${ts}.out_build_dir}%.d, $(notdir $(strip ${1})))

${ts}.deps = \
	${$(call GetTargetStructName,surelog).output_files} \
	${$(call GetTargetStructName,yosys).output_files}

${ts}.input_files = \
	${${ts}.sources} \
	${${ts}.deps}

${ts}.output_files := \
	$(call ${ts}.MapSourceToObjectFile,${${ts}.sources}) \
	${${ts}.out_lib_file}

${ts}.output_dirs := \
	${out_dir} \
	$(sort $(dir ${${ts}.output_files}))

${ts}.install_copy_list := \
	${${ts}.out_lib_file}:share/yosys/plugins/


# Variable evaluation: $(eval $(value var))
define ${ts}.rules
${${ts}.output_files} : ${${ts}.deps}

define single_object_rules
$(call ${ts}.MapSourceToObjectFile,${src}) : private target_src_file := ${src}
$(call ${ts}.MapSourceToObjectFile,${src}) : ${src} | $(dir $(call ${ts}.MapSourceToObjectFile,${src}))
-include $(call ${ts}.MapSourceToDependencyFile,${src})
endef
$(foreach src,${${ts}.sources},$(eval $(value single_object_rules)))
undefine single_object_rules

$(call ${ts}.MapSourceToObjectFile,${${ts}.sources}) :
	${CXX} ${CPPFLAGS} ${${ts}.cxxflags} -o $@ -c ${target_src_file}

${${ts}.out_lib_file} : $(call ${ts}.MapSourceToObjectFile,${${ts}.sources}) | $(dir ${${ts}.out_lib_file})
	${CXX} ${${ts}.ldflags} -shared -o $@ $(call ${ts}.MapSourceToObjectFile,${${ts}.sources}) ${${ts}.ldlibs}
endef
