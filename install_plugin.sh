#!/usr/bin/env bash

set -e

if ! command -v yosys-config; then
    echo "yosys-config not found! Do you have Yosys installed on your system?"
    exit 1
fi

YOSYS_DATDIR=$(yosys-config --datdir)
YOSYS_PLUGIN_DIR=$YOSYS_DATDIR/plugins

INSTALL_SCRIPT_DIR=$(dirname $(realpath $0))
SYSTEMVERILOG_PLUGIN_PATH=$INSTALL_SCRIPT_DIR/out/current/share/yosys/plugins/systemverilog.so

mkdir -p $YOSYS_PLUGIN_DIR
cp -v $SYSTEMVERILOG_PLUGIN_PATH $YOSYS_PLUGIN_DIR

if [[ -f /etc/os-release ]] && source /etc/os-release && [[ "$NAME" == *Debian* ]]; then
    # Debian has a different hardcoded plugin path, not reflected in yosys-config
    # https://salsa.debian.org/science-team/yosys/-/blob/master/debian/patches/0017-Support-plugin-loading-from-libdir.patch
    mkdir -p /usr/lib/yosys/plugins
    cp $SYSTEMVERILOG_PLUGIN_PATH /usr/lib/yosys/plugins
fi
