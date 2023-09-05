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
test_cases=( $(cd ${REPO_DIR}/uhdm-tests && echo simple_tests/!(${filter_pat})) )

global_status=0
mkdir -p "$(dirname "$RESULTS_FILE")"

# Test

cd $REPO_DIR
for test_case in "${test_cases[@]}"; do
    printf '::group::%s\n' "$test_case"
    export test_case
    test_name="${test_case//tests\//}"
    test_name="${test_name//\//_}"

    test_out_dir="${OUT_DIR}/${test_name}"
    mkdir -p "$test_out_dir"

    (
        # Used only for current test
        ASAN_OPTIONS+=":log_path=${test_out_dir}/asan"

        # libfakedlclose.so has to be used with yosys to prevent
        # systemverilog.so from being unloaded by yosys as part of cleanup
        # before termination. ASAN needs it to be in memory to correctly
        # symbolize function addresses.
        make -C $REPO_DIR/uhdm-tests \
                -j $(nproc) \
                --no-print-directory \
                YOSYS_BIN:="LD_PRELOAD=${REPO_DIR}/image/lib/libfakedlclose.so ${REPO_DIR}/image/bin/yosys -Q" \
                ENABLE_READLINE=0 \
                PRETTY=0 \
                PARSER=$PARSER \
                TEST=$test_case \
                $TARGET > "${test_out_dir}/yosys.log"
    )
    (( $? == 0 )) && test_ok=1 || test_ok=0

    sed -i -n \
        -e "s#${REPO_DIR}/##g" \
        -e '/1. Executing Verilog with UHDM frontend./,$ {/^End of script/d; /^Time spent/d; p}' \
        "${test_out_dir}/yosys.log"

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

    # uhdm-tests/Makefile runs yosys with CWD set to `uhdm-tests/build` directory.
    # Some tests write `yosys.sv` file in the CWD.
    if [[ -e $REPO_DIR/uhdm-tests/build/yosys.sv ]]; then
        mv "$REPO_DIR/uhdm-tests/build/yosys.sv" "${test_out_dir}/"
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
        printf '\x1b[0;39;1;3mUp to last 50 lines of yosys log:\x1b[0m\n'
        tail -n 50 ${test_out_dir}/yosys.log
        global_status=1
    fi

    printf '%d\t%d\t%s\n' "$test_ok" "$asan_ok" "$test_name" >> "$RESULTS_FILE"
    printf '::endgroup::\n'
done

# Leave with non-zero error status if any test failed
if [[ $global_status -ne 0 ]]; then
    exit 1
fi
