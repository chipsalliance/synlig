#!/bin/bash

set -e -x

if [ -z "$GITHUB_ACTIONS" ]; then
	DEPENDENCIES="make libgoogle-perftools4 libgoogle-perftools-dev libreadline8 gcc-11 bison \
	    libtcl8.6 libffi-dev tcl-dev flex libfl-dev swig g++-11 build-essential cmake wget time \
	    jq git python3 python3-dev python3-pip python3-orderedmultidict libreadline-dev uuid \
	    default-jre gettext-base libcairo2-dev google-perftools libtinfo5 python3-virtualenv \
	    uuid-dev libftdi1-dev ninja-build srecord tclsh rustc graphviz-dev ant python3-click"
else
	DEPENDENCIES="python3-virtualenv srecord swig tcl-dev tclsh time uuid uuid-dev wget ant \
		build-essential cmake default-jre flex git google-perftools graphviz jq libreadline-dev \
		libffi-dev libfl-dev libftdi1-dev libgoogle-perftools-dev libgraphviz-dev libcairo2-dev \
		libtinfo5 llvm-15 ninja-build pkg-config python3 python3-click python3-dev python3-pip"
fi

function install_dependencies(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Install dependencies \##"
	apt update && apt install -y $DEPENDENCIES
	update-alternatives --install /usr/bin/python python /usr/bin/python3 1
	update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
}

function load_submodules(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Load submodules \##"
	git submodule sync
	recursive=""
	for arg in $@
	do
		[ $arg == "-r" ] && recursive="--recursive"
		if [ $arg != "load_submodules" ] && [ $arg != "-r" ]; then
			git submodule update --depth 1 --init $recursive --checkout third_party/$arg
		fi
	done
}
