#!/bin/sh

YOSYS_DATDIR=$(yosys-config --datdir)
YOSYS_PLUGIN_DIR=$YOSYS_DATDIR/plugins

INSTALL_SCRIPT_DIR=$(dirname $(realpath $0))
UHDM_PLUGIN_PATH=$INSTALL_SCRIPT_DIR/image/share/yosys/plugins/uhdm.so

mkdir -p $YOSYS_PLUGIN_DIR
cp -v $UHDM_PLUGIN_PATH $YOSYS_PLUGIN_DIR
