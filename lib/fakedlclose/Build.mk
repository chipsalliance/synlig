t         := fakedlclose
ts        := $(call GetTargetStructName,${t})
build_dir := $(call GetTargetBuildDir,${t})

${ts}.src_dir         := $(call ToAbsDirPaths,$(dir ${THIS_BUILD_MK}))

${ts}.sources := ${${ts}.src_dir}fakedlclose.c

${ts}.out_lib_file := ${build_dir}libfakedlclose.so

${ts}.input_files = ${${ts}.sources}

${ts}.output_files := ${${ts}.out_lib_file}

${ts}.output_dirs := ${build_dir}

${ts}.install_copy_list := ${${ts}.out_lib_file}:lib/

define ${ts}.rules
${${ts}.out_lib_file} : ${${ts}.sources} | $(dir ${${ts}.out_lib_file})
	${CC} ${${ts}.ldflags} -shared -o $@ ${${ts}.sources}
endef
