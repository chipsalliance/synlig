t       := surelog
ts      := $(call GetTargetStructName,${t})
out_dir := $(call GetTargetBuildDir,${t})

${ts}.src_dir         := ${TOP_DIR}third_party/surelog/
${ts}.out_build_dir   := ${out_dir}build/
${ts}.out_install_dir := ${out_dir}install/

${ts}.input_files := $(shell \
	find ${${ts}.src_dir} \
		-path '*/.*' -prune -o \
		-path '${${ts}.src_dir}build' -prune -o \
		-path '${${ts}.src_dir}tests' -prune -o \
		-path '${${ts}.src_dir}third_party/tests' -prune -o \
		-path '${${ts}.src_dir}third_party/UHDM/tests' -prune -o \
		-path '${${ts}.src_dir}third_party/antlr4/runtime/Cpp/demo' -prune -o \
		-name 'compile_commands.json' -o \
		-type f -print \
		| sed "s/ /\\\\ /g" \
)

${ts}.output_files := \
	${${ts}.out_install_dir}lib/libsurelog.a \
	${${ts}.out_install_dir}lib/libuhdm.a \
	${${ts}.out_install_dir}lib/pkgconfig/Surelog.pc \
	${${ts}.out_install_dir}lib/pkgconfig/UHDM.pc

${ts}.output_dirs := \
	${out_dir} \
	${${ts}.out_build_dir} \
	${${ts}.out_install_dir}

${ts}.install_copy_list := \
	${${ts}.out_install_dir}bin/*:bin/ \
	${${ts}.out_install_dir}share/*:share/

${ts}.output_vars.PKG_CONFIG_PATH := ${${ts}.out_install_dir}lib/pkgconfig/

ifeq (${BUILD_TYPE},release)
${ts}.cmake_build_type := Release
else
${ts}.cmake_build_type := Debug
endif


# Variable evaluation: in recipe, ${var}
define ${ts}.build_command
	cd ${${ts}.out_build_dir}

	$(if ${LD},export LDFLAGS=$(call ShQuote,${LDFLAGS} ${USE_LD_FLAG}))
	if ! [[ -e Makefile ]]; then
		cmake \
				-DCMAKE_INSTALL_MODE=REL_SYMLINK_OR_COPY \
				-DCMAKE_INSTALL_MESSAGE=LAZY \
				-DCMAKE_TARGET_MESSAGES=OFF \
				-DCMAKE_COLOR_DIAGNOSTICS=$(if MAKE_TERMOUT,ON,OFF) \
				-DCMAKE_EXPORT_COMPILE_COMMANDS=OFF \
				-DCMAKE_BUILD_TYPE=${${ts}.cmake_build_type} \
				-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
				-DINSTALL_GTEST=OFF \
				-DSURELOG_BUILD_TESTS=OFF \
				-DANTLR_BUILD_SHARED=OFF \
				-DCMAKE_INSTALL_PREFIX=${${ts}.out_install_dir} \
				-S $(call ShQuote,${${ts}.src_dir}) \
				-B .
	fi
	${MAKE} --no-print-directory install
endef
