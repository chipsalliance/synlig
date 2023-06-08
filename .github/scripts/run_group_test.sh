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

# Prepare

tests_to_skip=(${TESTS_TO_SKIP:-})
filter_pat="$(IFS='|'; printf '%s\n' "${tests_to_skip[*]}")"
test_cases=( $(cd ${REPO_DIR}/UHDM-integration-tests && echo tests/!(${filter_pat})) )

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

    make -C $REPO_DIR/UHDM-integration-tests \
            -j $(nproc) \
            --no-print-directory \
            YOSYS_BIN:="${REPO_DIR}/image/bin/yosys -Q" \
            ENABLE_READLINE=0 \
            PRETTY=0 \
            PARSER=$PARSER \
            TEST=$test_case \
            $TARGET > "${test_out_dir}/yosys.log"
    (( $? == 0 )) && test_ok=1 || test_ok=0

    sed -i -n \
        -e "s#${REPO_DIR}/##g" \
        -e '/1. Executing Verilog with UHDM frontend./,$ {/^End of script/d; /^Time spent/d; p}' \
        "${test_out_dir}/yosys.log"

    # UHDM-integration-tests/Makefile runs yosys with CWD set to `UHDM-integration-tests/build` directory.
    # Some tests write `yosys.sv` file in the CWD.
    if [[ -e $REPO_DIR/UHDM-integration-tests/build/yosys.sv ]]; then
        mv "$REPO_DIR/UHDM-integration-tests/build/yosys.sv" "${test_out_dir}/"
    fi

    if (( $test_ok == 0 )); then
        printf '\x1b[0;39;1;3mUp to last 50 lines of yosys log:\x1b[0m\n'
        tail -n 50 ${test_out_dir}/yosys.log
        global_status=1
    fi

    printf '%d\t%d\t%s\n' "$test_ok" "$test_name" >> "$RESULTS_FILE"
    printf '::endgroup::\n'
done

# Leave with non-zero error status if any test failed
if [[ $global_status -ne 0 ]]; then
    exit 1
fi
