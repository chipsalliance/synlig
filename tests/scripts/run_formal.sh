#!/bin/bash
declare -r SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
declare -r REPO_DIR=$SELF_DIR/../..
cd $REPO_DIR

source tests/scripts/common.sh

function build_dependencies(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Build eqy and sby \##"
	make install@eqy install@sby -j $(nproc) PREFIX=out
}

function run_formal_tests(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start testing $1 \##"
	export PATH="$PWD/out/bin:$PATH"
	# this link is necessary because eqy doesn't
	# support specifying executable file correctly
	ln -f -s $(realpath $PWD/out/bin/synlig) $PWD/out/bin/yosys
	tests/formal/run_fv_tests.mk -j $(nproc) TEST_SUITE_DIR:="$2" TEST_SUITE_NAME:="$1" test
}

function gather_results(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Gather tests results \##"
	./tests/formal/gather_fv_results.sh $1
	exit $?
}

NAMEARG=0
args=$(getopt -o h -l name:,help -- "$@")

for arg in $args
do
	case "$arg" in
	-h|--help)
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
		exit 0
	;;
	--name) NAMEARG=1 ;;
	"'install_dependencies'") install_dependencies ;;
	"'build_dependencies'") build_dependencies ;;
	"'load_submodules'")
		[ "$name" == "'simple'" ] && load_submodules yosys -r eqy sby
		[ "$name" == "'yosys'" ] && load_submodules yosys -r eqy sby
		[ "$name" == "'sv2v'" ] && load_submodules yosys sv2v -r eqy sby
	;;
	"'run'")
		[ "$name" == "'simple'" ] && run_formal_tests simple ./tests/simple_tests
		[ "$name" == "'yosys'" ] && run_formal_tests yosys ./third_party/yosys/tests
		[ "$name" == "'sv2v'" ] && run_formal_tests sv2v ./third_party/sv2v/test
	;;
	"'gather_results'")
		[ "$name" == "'simple'" ] && gather_results simple ./tests/simple_tests
		[ "$name" == "'yosys'" ] && gather_results yosys ./third_party/yosys/tests
		[ "$name" == "'sv2v'" ] && gather_results sv2v
	;;
	--)
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
	;;
	*)
		if [ $NAMEARG -eq 1 ]; then
			name=$arg
		fi
		NAMEARG=0
	;;
	esac
done
exit 0
