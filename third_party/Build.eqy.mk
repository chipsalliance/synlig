t  := eqy
ts := $(call GetTargetStructName,${t})
${ts}.src_dir := ${TOP_DIR}/third_party/eqy/

${ts}.output_files := ${${ts}.src_dir}eqy

define ${ts}.build_command
	export PATH="$(realpath ${OUT_DIR})/bin:${PATH}"
	ln -f -s $(realpath ${OUT_DIR}/bin/synlig-config) ${OUT_DIR}/bin/yosys-config
	ln -f -s $(realpath ${OUT_DIR}/share/synlig) ${OUT_DIR}/share/yosys
	${MAKE} -C ${${ts}.src_dir} PREFIX=$(realpath ${OUT_DIR})
endef

define ${ts}.install_command
	export PATH="$(realpath ${OUT_DIR})/bin:${PATH}"
	ln -f -s $(realpath ${OUT_DIR}/bin/synlig-config) ${OUT_DIR}/bin/yosys-config
	ln -f -s $(realpath ${OUT_DIR}/share/synlig) ${OUT_DIR}/share/yosys
	${MAKE} -C ${${ts}.src_dir} install PREFIX=$(realpath ${OUT_DIR})
endef

