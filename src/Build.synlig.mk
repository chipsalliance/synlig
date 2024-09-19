t  := synlig
ts := $(call GetTargetStructName,${t})

cxx_is_clang := $(findstring clang,$(notdir ${CXX}))

${ts}.out_install_dir := $(call ToAbsPaths,${OUT_DIR})

${ts}.output_files := \
	${${ts}.src_dir}synlig

${ts}.deps = \
	${$(call GetTargetStructName,surelog).output_files}

${ts}.input_files = \
	${${ts}.deps}

${ts}.make_args := \
	PREFIX:=$(call ToAbsPaths,${PREFIX}) \
	PYTHON_PREFIX:=$(call ToAbsPaths,${PYTHON_PREFIX}) \
	DESTDIR:=$(if $(DESTDIR),$(call ToAbsPaths,$(DESTDIR)),) \
	CONFIG:=$(if cxx_is_clang,clang,gcc) \
	CC:=${CC} \
	CXX:=${CXX} \
	LD:=${CXX} \
	$(if ${LD},LDFLAGS:=$(call ShQuote,${LDFLAGS} ${USE_LD_FLAG})) \
	SYNLIG_BUILD_TYPE:=$(BUILD_TYPE) \
	SYNLIG_BUILD_DIR:=$(call ToAbsPaths,$(BUILD_DIR))

cxxflags := ${CXXFLAGS}

ifeq (${BUILD_TYPE},asan)
${ts}.make_args += SANITIZER:=address
ifdef cxx_is_clang
cxxflags += -fsanitize-address-use-after-return=always
endif
${ts}.make_args += \
	ENABLE_DEBUG:=1 \
	STRIP:=/bin/true
endif

ifdef cxxflags
${ts}.make_args += CPPFLAGS:=$(call ShQuote,${CXXFLAGS})
undefine cxxflags
endif

define ${ts}.build_command
	mkdir -p $(BUILD_DIR)/synlig
	${MAKE} ${${ts}.make_args} -C $(BUILD_DIR)/synlig -f $(TOP_DIR)/src/Makefile
endef

define ${ts}.install_command
	mkdir -p $(BUILD_DIR)/synlig
	${MAKE} ${${ts}.make_args} -C $(BUILD_DIR)/synlig -f $(TOP_DIR)/src/Makefile install
endef

define ${ts}.src_clean_command
	if [ -d $(BUILD_DIR)/synlig ]; then
		${MAKE} -C $(BUILD_DIR)/synlig -f $(TOP_DIR)/src/Makefile clean
	fi
endef
