t  := sv2v
ts := $(call GetTargetStructName,${t})
${ts}.src_dir := ${TOP_DIR}/third_party/sv2v/

${ts}.output_files := ${${ts}.src_dir}sv2v

define ${ts}.build_command
	${MAKE} -C ${${ts}.src_dir}
	mkdir -p ${OUT_DIR}/bin
endef

define ${ts}.install_command
	cp ./third_party/sv2v/bin/sv2v ${OUT_DIR}/bin/sv2v
endef

