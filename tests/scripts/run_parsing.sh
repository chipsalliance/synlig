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

function read_systemverilog(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start testing read_systemverilog \##"
	export PATH="$PATH:$(realpath out/bin)"
	BUILD_TYPE=$type \
	TESTS_TO_SKIP=$SKIP \
	TARGET=uhdm/yosys/test-ast \
	PARSER=yosys-plugin \
	./.github/scripts/run_group_test.sh ./build/parsing/${type}-read-systemverilog ./build/parsing/${type}-test-results-systemverilog.log
	exit $?
}

function read_uhdm(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start testing read_uhdm \##"
	export PATH="$PATH:$(realpath out/bin)"
	BUILD_TYPE=$type \
	TESTS_TO_SKIP=$SKIP \
	TARGET=uhdm/yosys/test-ast \
	PARSER=surelog \
	./.github/scripts/run_group_test.sh ./build/parsing/${type}-read-uhdm ./build/parsing/${type}-test-results-uhdm.log
	exit $?
}

TYPEARG=0
args=$(getopt -o h -l type:,help -- "$@")

for arg in $args
do
	case "$arg" in
	-h|--help)
		echo "Usage $0:"
		echo "    --type <build type>"
		echo ""
		echo "    install_dependencies - installs necessary dependencies"
		echo ""
		echo "    load_submodules - clones necessary submodules"
		echo ""
		echo "    read_uhdm -          tests read_uhdm command"
		echo "    read_systemverilog - tests read_systemverilog command"
		echo ""
		echo "    gather_results - prints summary for performed tests"
		echo ""
		echo "    List of supported build types:"
		echo "        asan"
		echo "        release"
		echo "        plugin"
		echo ""
		exit 0
	;;
	--type) TYPEARG=1 ;;
	"'install_dependencies'") install_dependencies ;;
	"'load_submodules'") load_submodules -r surelog ;;
	"'read_uhdm'") read_uhdm ;;
	"'read_systemverilog'") read_systemverilog ;;
	"'gather_results'")
		.github/scripts/generate_summary.sh $type ./build/parsing
	;;
	--)
		if [ -z $type ]; then
			echo "Build type is not provided!"
			exit 1
		else
			[ "$type" == "asan" ] && valid=1
			[ "$type" == "release" ] && valid=1
			[ "$type" == "plugin" ] && valid=1
			if [ -z $valid ]; then
				echo "Provided build type is not valid!"
				exit 1
			fi
		fi
	;;
	*)
		if [ $TYPEARG -eq 1 ]; then
			type=${arg//\'/}
		fi
		TYPEARG=0
	;;
	esac
done
exit 0
