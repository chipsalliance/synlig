#!/bin/bash
declare -r SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
declare -r REPO_DIR=$SELF_DIR/../..
cd $REPO_DIR

source tests/scripts/common.sh

SKIP="synthesis serv-minimal hello-uvm assignment-pattern MultiplePrints \
	VoidFunction2Returns VoidFunctionWithoutReturn cmake OneThis FunctionOutputArgument \
	SelectFromUnpackedInFunction VoidFunction NestedPatternPassedAsPort SystemFunctions \
	ParameterDoubleUnderscoreInSvFrontend ImportPackageWithFunction DpiChandle OneClass \
	OutputSizeWithParameterOfInstanceInitializedByStructMember StringAssignment Disable \
	StringAssignConcatenation StringLocalParamInitByConcatenation StringWithBackslash \
	AssignToUnpackedUnionFieldAndReadOtherField Forever"

function test_read_systemverilog(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start testing read_systemverilog \##"
	TESTS_TO_SKIP=$SKIP \
	TARGET=uhdm/yosys/test-ast \
	PARSER=yosys-plugin \
	./.github/scripts/run_group_test.sh ./build/parsing/read-systemverilog ./build/parsing/test-results-systemverilog.log
	exit $?
}

function test_read_uhdm(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start testing read_uhdm \##"
	TESTS_TO_SKIP=$SKIP \
	TARGET=uhdm/yosys/test-ast \
	PARSER=surelog \
	./.github/scripts/run_group_test.sh ./build/parsing/read-uhdm ./build/parsing/test-results-uhdm.log
	exit $?
}

args=$(getopt -o h -l help -- "$@")

for arg in $args
do
	if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]; then
		echo "Usage $0:"
		echo "    install_dependencies - installs necessary dependencies"
		echo ""
		echo "    load_submodules - clones necessary submodules"
		echo ""
		echo "    read_uhdm -          tests read_uhdm command"
		echo "    read_systemverilog - tests read_systemverilog command"
		echo ""
	fi

	if [ "$arg" == "'install_dependencies'" ]; then
		install_dependencies
	fi

	if [ "$arg" == "'load_submodules'" ]; then
		load_submodules -r surelog
	fi

	if [ "$arg" == "'read_uhdm'" ]; then
		test_read_uhdm
	fi

	if [ "$arg" == "'read_systemverilog'" ]; then
		test_read_systemverilog
	fi
done
