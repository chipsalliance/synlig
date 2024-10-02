#!/bin/bash
declare -r SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
declare -r REPO_DIR=$SELF_DIR/../..
cd $REPO_DIR

source tests/scripts/common.sh

function run_veer(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start Veer large design test \##"
	make -C tests uhdm/synlig/veer TEST=veer ENABLE_READLINE=0 PRETTY=0 -j $(nproc)
	exit $?
}

function run_blackparrot_AMD(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start Blackparrot AMD large design test \##"
	make -C tests uhdm/synlig/synth-blackparrot-build TEST=black_parrot ENABLE_READLINE=0 PRETTY=0 -j $(nproc)
	exit $?
}

function run_blackparrot_AMD_python(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start Blackparrot AMD large design test (with Synlig as python module) \##"
	make -C tests uhdm/synlig/synth-blackparrot-build-python TEST=black_parrot ENABLE_READLINE=0 PRETTY=0 -j $(nproc)
	exit $?
}

function run_blackparrot_ASIC(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start Blackparrot ASIC large design test \##"
	make -C tests uhdm/synlig/synth-blackparrot-build-asic TEST=black_parrot -j $(nproc)
	exit $?
}

function run_ibex(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start Ibex large design test \##"
	make -C tests uhdm/synlig/synth-ibex-build TEST=ibex ENABLE_READLINE=0 PRETTY=0 -j $(nproc)
	exit $?
}

function run_ibex_f4pga(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start Ibex f4pga large design test \##"
	# Environment creation has to be run with one job to avoid race conditions.
	# See: https://github.com/SymbiFlow/make-env/pull/40
	# Even with the fix more jobs doesn't help with anything.
	make -C ./tests env TEST=ibex -j1
	make -C tests uhdm/yosys/synth-ibex-f4pga TEST=ibex ENABLE_READLINE=0 PRETTY=0 -j $(nproc)
	exit $?
}

function run_opentitan_9d82960888(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start Opentitan 9d82960888 large design test \##"
	make -C tests uhdm/synlig/synth-opentitan-build TEST=opentitan ENABLE_READLINE=0 PRETTY=0 -j $(nproc)
	exit $?
}

function run_opentitan(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start Opentitan large design test \##"
	make -C tests uhdm/synlig/synth-opentitan-build-tiny TEST=opentitan ENABLE_READLINE=0 PRETTY=0 -j $(nproc)
	exit $?
}

function run_opentitan_parse_quick(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start Opentitan large design test \##"
	export PATH="$PWD/out/bin:$PATH"
	cd tests/opentitan/opentitan_parsing_test
	make gen-opentitan-deps-mk
	make -rR -j$(nproc) -Otarget test || /bin/true
	make summary
	make summary.md
	cat build/results/summary.md && rm build/results/summary.md
	make check-status
	exit $?
}

function run_opentitan_parse_full(){
	[ -z "$GITHUB_ACTIONS" ] && echo "##/ Start Opentitan large design test \##"
	export PATH="$PWD/out/bin:$PATH"
	cd tests/opentitan/opentitan_parsing_test
	make gen-opentitan-deps-mk
	make -rR -j$(nproc) TOP_DOWN_TEST:=1 -Otarget test || /bin/true
	make summary
	make summary.md
	cat build/results/summary.md && rm build/results/summary.md
	make check-status
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
		echo "    load_submodules        - loads necessary submodules"
		echo "    run                    - launches large design test"
		echo ""
		echo "    List of supported large design test names:"
		echo "        veer"
		echo "        blackparrot_AMD"
		echo "        blackparrot_AMD_python"
		echo "        blackparrot_ASIC"
		echo "        ibex"
		echo "        ibex_f4pga"
		echo "        opentitan_9d82960888"
		echo "        opentitan"
		echo "        opentitan_parse_quick"
		echo "        opentitan_parse_full"
		exit 0
	;;
	--name) NAMEARG=1 ;;
	"'install_dependencies'") install_dependencies ;;
	"'load_submodules'")
		[ "$name" == "'veer'" ] && load_submodules -r veer
		[ "$name" == "'blackparrot_AMD'" ] && load_submodules black_parrot_tools black_parrot_sdk -r black_parrot
		[ "$name" == "'blackparrot_AMD_python'" ] && load_submodules black_parrot_tools black_parrot_sdk -r black_parrot
		[ "$name" == "'blackparrot_ASIC'" ] && load_submodules black_parrot_tools black_parrot_sdk OpenROAD-flow-scripts -r black_parrot
		[ "$name" == "'ibex'" ] && load_submodules -r make_env ibex
		[ "$name" == "'ibex_f4pga'" ] && load_submodules -r make_env ibex yosys_f4pga_plugins
		[ "$name" == "'opentitan_9d82960888'" ] && load_submodules -r opentitan_9d82960888
		[ "$name" == "'opentitan'" ] && load_submodules -r opentitan
		[ "$name" == "'opentitan_parse_quick'" ] && load_submodules -r opentitan
		[ "$name" == "'opentitan_parse_full'" ] && load_submodules -r opentitan
	;;
	"'run'")
		[ "$name" == "'veer'" ] && run_veer
		[ "$name" == "'blackparrot_AMD'" ] && run_blackparrot_AMD
		[ "$name" == "'blackparrot_AMD_python'" ] && run_blackparrot_AMD_python
		[ "$name" == "'blackparrot_ASIC'" ] && run_blackparrot_ASIC
		[ "$name" == "'ibex'" ] && run_ibex
		[ "$name" == "'ibex_f4pga'" ] && run_ibex_f4pga
		[ "$name" == "'opentitan_9d82960888'" ] && run_opentitan_9d82960888
		[ "$name" == "'opentitan'" ] && run_opentitan
		[ "$name" == "'opentitan_parse_quick'" ] && run_opentitan_parse_quick
		[ "$name" == "'opentitan_parse_full'" ] && run_opentitan_parse_full
	;;
	--)
		if [ -z $name ]; then
			echo "Large design test name is not provided!"
			exit 1
		else
			[ "$name" == "'veer'" ] && valid=1
			[ "$name" == "'blackparrot_AMD'" ] && valid=1
			[ "$name" == "'blackparrot_AMD_python'" ] && valid=1
			[ "$name" == "'blackparrot_ASIC'" ] && valid=1
			[ "$name" == "'ibex'" ] && valid=1
			[ "$name" == "'ibex_f4pga'" ] && valid=1
			[ "$name" == "'opentitan_9d82960888'" ] && valid=1
			[ "$name" == "'opentitan'" ] && valid=1
			[ "$name" == "'opentitan_parse_quick'" ] && valid=1
			[ "$name" == "'opentitan_parse_full'" ] && valid=1
			if [ -z $valid ]; then
				echo "Provided large design test name is not valid!"
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
