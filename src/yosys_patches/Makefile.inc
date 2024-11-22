SYNLIG_SRC ?= $(TOP_DIR)/src
YOSYS_SRC ?= $(TOP_DIR)/third_party/yosys
PATCHES_DIR := $(SYNLIG_SRC)/yosys_patches

apply_yosys_patches:
	if ! (cd $(YOSYS_SRC) && git apply --reverse --check $(PATCHES_DIR)/*.patch 2> /dev/null); then (cd $(YOSYS_SRC) && git apply $(PATCHES_DIR)/*.patch); fi
