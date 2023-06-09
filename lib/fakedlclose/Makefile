override this_mk.file := $(abspath $(lastword ${MAKEFILE_LIST}))
override this_mk.dir := $(patsubst /%/,/%,$(dir ${this_mk.file}))

#───────────────────────────────────────────────────────────────────────────────
# Configuration
#───────────────────────────────────────────────────────────────────────────────

CC ?= cc
INSTALL_DIR :=

#───────────────────────────────────────────────────────────────────────────────
# Build
#───────────────────────────────────────────────────────────────────────────────

so_name := ${this_mk.dir}/libfakedlclose.so
srcs := ${this_mk.dir}/fakedlclose.c

${so_name}: ${srcs}
	${CC} -o $@ -shared $^

#───────────────────────────────────────────────────────────────────────────────
# Clean
#───────────────────────────────────────────────────────────────────────────────

.PHONY: clean
clean:
	rm -f ${so_name}

#───────────────────────────────────────────────────────────────────────────────
# Install
#───────────────────────────────────────────────────────────────────────────────

.PHONY: install
ifneq (${INSTALL_DIR},)
${INSTALL_DIR}/lib:
	mkdir -p $@

install: ${so_name} | ${INSTALL_DIR}/lib
	cp ${so_name} ${INSTALL_DIR}/lib/

else
install: ${so_name}
	$(error Installation not possible - INSTALL_DIR not specified)
endif
