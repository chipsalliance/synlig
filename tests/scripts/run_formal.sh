#!/bin/bash
declare -r SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
declare -r REPO_DIR=$SELF_DIR/../..
cd $REPO_DIR

source tests/scripts/common.sh

function build_dependencies(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Build eqy and sby \##"
	make build_eqy build_sby -j $(nproc)
}

function run_formal_tests(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start testing $1 \##"
	export PATH="$PWD/out/current/bin:$PATH"
	./run_fv_tests.mk -j $(nproc) TEST_SUITE_DIR:="$2" TEST_SUITE_NAME:="$1" test
}

function gather_results(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Gather tests results \##"
	./tests/formal/gather_fv_results.sh $1
	exit $?
}

args=$(getopt -o h -l name:,help -- "$@")

for arg in $(echo $args | sed -s "s/--name /--name~/")
do
	if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]; then
		echo "Usage $0:"
		echo "    --name <test_suite_name>"
		echo ""
		echo "    install_dependencies   - installs necessary dependencies"
		echo "    build_dependencies     - builds necessary dependencies"
		echo "    load_submodules        - clones necessary submodules"
		echo "    run                    - launches FV"
		echo "    gather_results         - gathers results of FV"
		echo ""
		echo "    List of supported test suite names:"
		echo "        simple"
		echo "        yosys"
		echo "        sv2v"
		echo ""
	fi

	option=$(echo $arg | cut -d '~' -f 1)
	if [ $option == "--name" ]; then
		name=$(echo $arg | cut -d '~' -f 2)
	fi

	if [ "$arg" == "--" ]; then
		if [ -z $name ]; then
			echo "Test suite name is not provided!"
			exit 1
		else
			[ "$name" == "'simple'" ] && valid=1
			[ "$name" == "'yosys'" ] && valid=1
			[ "$name" == "'sv2v'" ] && valid=1
			if [ -z $valid ]; then
				echo "Provided test suite name is not valid!"
				exit 1
			fi
		fi
	fi

	[ "$arg" == "'install_dependencies'" ] && install_dependencies
	[ "$arg" == "'build_dependencies'" ] && build_dependencies

	if [ "$arg" == "'load_submodules'" ]; then
		[ "$name" == "'simple'" ] && load_submodules -r eqy sby
		[ "$name" == "'yosys'" ] && load_submodules yosys -r eqy sby
		[ "$name" == "'sv2v'" ] && load_submodules sv2v -r eqy sby
	fi

	if [ "$arg" == "'run'" ]; then
		[ "$name" == "'simple'" ] && run_formal_tests simple ./tests/simple_tests
		[ "$name" == "'yosys'" ] && run_formal_tests yosys ./third_party/yosys/tests
		[ "$name" == "'sv2v'" ] && run_formal_tests sv2v ./third_party/sv2v/test
	fi

	if [ "$arg" == "'gather_results'" ]; then
		[ "$name" == "'simple'" ] && gather_results simple ./tests/simple_tests
		[ "$name" == "'yosys'" ] && gather_results yosys ./third_party/yosys/tests
		[ "$name" == "'sv2v'" ] && gather_results sv2v
	fi
done
