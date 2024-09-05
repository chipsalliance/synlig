#!/bin/bash
shopt -s nullglob
shopt -s extglob

declare -r SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
declare -r REPO_DIR="$(realpath $SELF_DIR/../..)"

# Inputs
declare -r OUT_DIR="$(realpath -m "$1")"

declare -r RESULTS_FILE="$(realpath -m "$2")"

# Input passed via env:
# - PARSER
# - TARGET
# - BUILD_TYPE

# Configure ASAN & LSAN

declare -a asan_options=(
    exitcode=0
    detect_stack_use_after_return=1
    check_initialization_order=1
    detect_leaks=1
    handle_abort=1
    suppressions=$REPO_DIR/config/asan.supp
    log_suffix=.log
)
declare -a lsan_options=(
    suppressions=$REPO_DIR/config/lsan.supp
)
export ASAN_OPTIONS="$(IFS=':'; printf '%s' "${asan_options[*]}")"
export LSAN_OPTIONS="$(IFS=':'; printf '%s' "${lsan_options[*]}")"
export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer-15

# Prepare

tests_to_skip=(${TESTS_TO_SKIP:-})
filter_pat="$(IFS='|'; printf '%s\n' "${tests_to_skip[*]}")"
test_cases=( $(cd ${REPO_DIR}/tests && echo simple_tests/!(${filter_pat})) )

global_status=0
mkdir -p "$(dirname "$RESULTS_FILE")"

declare -a failed_tests_list

# Test

cd $REPO_DIR
for test_case in "${test_cases[@]}"; do
    if [ -n "$GITHUB_ACTIONS" ]; then
        printf '::group::%s\n' "$test_case"
    else
        printf "# %s #\n" "$test_case"
    fi
    export test_case
    test_name="${test_case//tests\//}"
    test_name="${test_name//\//_}"

    test_out_dir="${OUT_DIR}/${test_name}"
    mkdir -p "$test_out_dir"

    (
        # Used only for current test
        ASAN_OPTIONS+=":log_path=${test_out_dir}/asan"

        if [ "$BUILD_TYPE" == "plugin" ]; then
            BINARY="yosys -Q"
        else
            BINARY="synlig -Q"
        fi
        make -C $REPO_DIR/tests \
                -j $(nproc) \
                --no-print-directory \
                BINARY:="$BINARY" \
                BUILD_TYPE=$BUILD_TYPE \
                ENABLE_READLINE=0 \
                PRETTY=0 \
                PARSER=$PARSER \
                TEST=$test_case \
                $TARGET > "${test_out_dir}/synlig.log"
    )
    (( $? == 0 )) && test_ok=1 || test_ok=0

    sed -i -n \
        -e "s#${REPO_DIR}/##g" \
        -E -e '/1. Executing (Verilog with )?UHDM frontend./,$ {/^End of script/d; /^Time spent/d; p}' \
        "${test_out_dir}/synlig.log"

    # ASAN log contains PID in the name. There should be only one log, but even
    # assuming more processes were spawned, we can quite safely concatenate
    # them for the purpose of error detection.
    test_asan_logs=( ${test_out_dir}/asan.*.log )
    # ASAN log is generated even when no errors were reported, e.g. to print
    # suppresion statistics. To find out whether there were errors or not
    # we can look for lines with errors and summary.
    asan_summary=''
    asan_ok=1
    if (( ${#test_asan_logs[@]} > 0 )); then
        asan_summary="$(grep -h '^=[0-9=]*=.*: .*\|^SUMMARY:.*' "${test_asan_logs[@]}")"
        (( $? == 1 )) && asan_ok=1 || asan_ok=0
        if (( asan_ok == 0 )); then
            global_status=1
        fi
    fi

    # tests/Makefile runs yosys with CWD set to `tests/build` directory.
    # Some tests write `yosys.sv` file in the CWD.
    if [[ -e $REPO_DIR/tests/build/yosys.sv ]]; then
        mv "$REPO_DIR/tests/build/yosys.sv" "${test_out_dir}/"
    fi

    if (( $asan_ok == 0 )); then
        printf '\x1b[0;39;1;3mASAN issues:\x1b[0m\n'
        printf '\x1b[31m%s\x1b[0m\n' "$line"
        while read line; do
            if [[ -n "$line" ]]; then
                printf '\x1b[31m%s\x1b[0m\n' "$line"
            fi
        done <<<"$asan_summary"
        echo
    fi

    if (( $test_ok == 0 )); then
        printf '\x1b[0;39;1;3mUp to last 50 lines of synlig log:\x1b[0m\n'
        tail -n 50 ${test_out_dir}/synlig.log
        global_status=1
    fi

    printf '%d\t%d\t%s\n' "$test_ok" "$asan_ok" "$test_name" >> "$RESULTS_FILE"
    if [ -n "$GITHUB_ACTIONS" ]; then
        printf '::endgroup::\n'
    else
        if (( $test_ok == 1 )); then
            printf "|  PASS\n\n"
        else
            failed_tests_list+=("$test_name")
        fi
    fi
done

if [ -z "$GITHUB_ACTIONS" ] && [[ $global_status -ne 0 ]]; then
    echo "Failed tests list:"
    for test_name in ${failed_tests_list[@]}
    do
		echo $test_name
    done
fi

# Leave with non-zero error status if any test failed
if [[ $global_status -ne 0 ]]; then
    exit 1
fi
