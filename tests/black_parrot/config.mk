## Set common environment variables
include $(TOP)/Makefile.common

export DESIGN_NICKNAME = wrapper
export DESIGN_NAME = wrapper
export PLATFORM    = nangate45

export SYNTH_HIERARCHICAL = 1
export RTLMP_FLOW = True
#
# RTL_MP Settings
export RTLMP_MAX_INST = 30000
export RTLMP_MIN_INST = 5000
export RTLMP_MAX_MACRO = 12
export RTLMP_MIN_MACRO = 4

export ABC_AREA = 1

export SDC_FILE = $(TEST_DIR)/constraint.sdc

export DIE_AREA    = 0 0 1350 1300
export CORE_AREA   = 10.07 11.2 1340 1290

export PLACE_PINS_ARGS = -exclude left:* -exclude right:* -exclude top:* -exclude bottom:0-100 -exclude bottom:1200-1350

export PLACE_DENSITY_LB_ADDON = 0.05

export MACRO_PLACE_HALO    = 10 10
export MACRO_PLACE_CHANNEL = 20 20
export TNS_END_PERCENT     = 100
