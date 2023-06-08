#!/bin/bash
declare -r SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
declare -r REPO_DIR="$(realpath $SELF_DIR/../..)"

# Inputs
declare -r OUT_DIR="$(realpath -m "$1")"

declare -r RESULTS_FILE_PREFIX="$(realpath -m "$2")"

declare -r passed_results_file="${RESULTS_FILE_PREFIX}.passed"
declare -r failed_results_file="${RESULTS_FILE_PREFIX}.failed"

# Input passed via env:
# - PARSER
# - TARGET

# Configure ASAN & LSAN

declare -a asan_options=(
    detect_stack_use_after_return=1
    check_initialization_order=1
    detect_leaks=1
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

if [[ -z $TESTS_TO_SKIP ]]; then
    TEST_CASES="$(cd UHDM-integration-tests && python list.py -d tests)"
else
    TEST_CASES="$(cd UHDM-integration-tests && python list.py -d tests -s $TESTS_TO_SKIP)"
fi
TEST_CASES=$(echo $TEST_CASES | sed "s/[][,\"]//g") # Remove characters '[', ']', '"' and ',' from json like array

RET=0
mkdir -p "$(dirname "$RESULTS_FILE_PREFIX")"

# Test

cd $REPO_DIR
for TEST_CASE in $TEST_CASES; do
    printf '::group::%s\n' "$TEST_CASE"
    export TEST_CASE
    TEST_NAME="${TEST_CASE//tests\//}"
    TEST_NAME="${TEST_NAME//\//_}"

    test_out_dir="${OUT_DIR}/${TEST_NAME}"
    mkdir -p "$test_out_dir"

    (
        # Used only for current test
        ASAN_OPTIONS+=":log_path=${test_out_dir}/asan"

        make -C $REPO_DIR/UHDM-integration-tests -j $(nproc) \
                YOSYS_BIN:="LD_PRELOAD=${REPO_DIR}/image/lib/libfakedlclose.so ${REPO_DIR}/image/bin/yosys -Q" \
                ENABLE_READLINE=0 \
                PRETTY=0 \
                PARSER=$PARSER \
                TEST=$TEST_CASE \
                $TARGET > "${test_out_dir}/yosys.log"
    )
    TEST_RET=$?

    # UHDM-integration-tests/Makefile runs yosys with CWD set to `UHDM-integration-tests/build` directory.
    # Some tests write `yosys.sv` file in the CWD.
    if [[ -e $REPO_DIR/UHDM-integration-tests/build/yosys.sv ]]; then
        mv "$REPO_DIR/UHDM-integration-tests/build/yosys.sv" "${test_out_dir}/"
    fi

    if [[ $TEST_RET -eq 0 ]]; then
        printf '%s\t%s\n' "$TEST_NAME" '1' >> "$passed_results_file"
    else
        printf '%s\n' "-- last 50 lines of the log --"
        tail -n 50 ${test_out_dir}/yosys.log
        printf '%s\n' "--"

        printf '%s\t%s\n' "$TEST_NAME" '0' >> "$failed_results_file"
        RET=1
    fi
    printf '::endgroup::\n'
done

# Leave with non-zero error status if any test failed
if [[ $RET -ne 0 ]]; then
    exit 1
fi
