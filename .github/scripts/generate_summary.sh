#!/bin/bash
set -e -u -o pipefail
shopt -s nullglob
shopt -s extglob

ROOT_DIR=$(dirname $(dirname $(dirname "$0")))
TEST_RESULTS_PREFIX=$ROOT_DIR/test-results
UHDM_PASSED_FILE=$TEST_RESULTS_PREFIX-uhdm.passed
UHDM_FAILED_FILE=$TEST_RESULTS_PREFIX-uhdm.failed
SYSTEMVERILOG_PASSED_FILE=$TEST_RESULTS_PREFIX-systemverilog.passed
SYSTEMVERILOG_FAILED_FILE=$TEST_RESULTS_PREFIX-systemverilog.failed

# Read passed tests if any exist
if [[ -e $UHDM_PASSED_FILE ]]; then
    UHDM_PASSED_NUMBER=$(wc -l < $UHDM_PASSED_FILE)
else
    UHDM_FAILED_NUMBER=0
fi
if [[ -e $SYSTEMVERILOG_PASSED_FILE ]]; then
    SYSTEMVERILOG_PASSED_NUMBER=$(wc -l < $SYSTEMVERILOG_PASSED_FILE)
else
    SYSTEMVERILOG_PASSED_NUMBER=0
fi

# Read failed tests if any exist
if [[ -e $UHDM_FAILED_FILE ]]; then
    UHDM_FAILED_NUMBER=$(wc -l < $UHDM_FAILED_FILE)
else
    UHDM_FAILED_NUMBER=0
fi
if [[ -e $SYSTEMVERILOG_FAILED_FILE ]]; then
    SYSTEMVERILOG_FAILED_NUMBER=$(wc -l < $SYSTEMVERILOG_FAILED_FILE)
else
    SYSTEMVERILOG_FAILED_NUMBER=0
fi

TOTAL_FAILED_TESTS=$(($UHDM_FAILED_NUMBER+$SYSTEMVERILOG_FAILED_NUMBER))
TOTAL_PASSED_TESTS=$(($UHDM_PASSED_NUMBER+$SYSTEMVERILOG_PASSED_NUMBER))
TOTAL_TESTS=$(($TOTAL_FAILED_TESTS+$TOTAL_PASSED_TESTS))

if [[ ! -e $UHDM_FAILED_FILE && ! -e $SYSTEMVERILOG_FAILED_FILE ]]; then
    echo ":heavy_check_mark: ALL TESTS PASSED :heavy_check_mark:" > $GITHUB_STEP_SUMMARY
else
    echo ":x: SOME TESTS FAILED :x:" > $GITHUB_STEP_SUMMARY
fi
echo "" >> $GITHUB_STEP_SUMMARY
echo "| Tool/Parser          | Failed | Passed |" >> $GITHUB_STEP_SUMMARY
echo "|:---------------------|-------:|-------:|" >> $GITHUB_STEP_SUMMARY
echo "| `read-uhdm`          | $UHDM_FAILED_NUMBER | $UHDM_PASSED_NUMBER |" >> $GITHUB_STEP_SUMMARY
echo "| `read-systemverilog` | $SYSTEMVERILOG_FAILED_NUMBER | $SYSTEMVERILOG_PASSED_NUMBER |" >> $GITHUB_STEP_SUMMARY
echo "| **Total**            | **$TOTAL_FAILED_TESTS** | **$TOTAL_PASSED_TESTS** |" >> $GITHUB_STEP_SUMMARY
echo "" >> $GITHUB_STEP_SUMMARY
echo "$TOTAL_FAILED_TESTS out of total $TOTAL_TESTS failed." >> $GITHUB_STEP_SUMMARY
echo "" >> $GITHUB_STEP_SUMMARY
echo "" >> $GITHUB_STEP_SUMMARY

declare -A uhdm_results=()
declare -A systemverilog_results=()
for result_file in "$SYSTEMVERILOG_FAILED_FILE" "$SYSTEMVERILOG_PASSED_FILE"; do
    if [[ -f "$result_file" ]]; then
        while read -r test_name test_result; do
            systemverilog_results[$test_name]=${test_result}
        done < "$result_file"
    fi
done
for result_file in "$UHDM_FAILED_FILE" "$UHDM_PASSED_FILE"; do
    if [[ -f "$result_file" ]]; then
        while read -r test_name test_result; do
            uhdm_results[$test_name]=${test_result}
        done < "$result_file"
    fi
done

# List of tests with specific combination of results.
# 0 means "fail", 1 means "pass". Each digit represents one column in the table
# (`read_uhdm` and `read_systemverilog`, respectivelly).
declare -a results_00=()
declare -a results_10=()
declare -a results_01=()
declare -a results_11=()

declare -r pass_str=':heavy_check_mark: **PASS**'
declare -r fail_str=':x: **FAIL**'

# `[^1]` below is used instead of `0` to catch any unexpected values as failures.
for test_name in "${!uhdm_results[@]}"; do
    case "${uhdm_results[$test_name]:-0}${systemverilog_results[$test_name]:-0}" in
        [^1][^1])
            results_00+=("| $fail_str | $fail_str | $test_name |")
        ;;
        1[^1])
            results_10+=("| $pass_str | $fail_str | $test_name |")
        ;;
        [^1]1)
            results_01+=("| $fail_str | $pass_str | $test_name |")
        ;;
        11)
            results_11+=("| $pass_str | $pass_str | $test_name |")
        ;;
    esac
done

print_ln() { printf '%s\n' "$@"; }

{
    if (( ${#results_00[@]} + ${#results_10[@]} + ${#results_01[@]} > 0 )); then
        print_ln '<details open>'
        print_ln '<summary><strong>List of failed tests</strong></summary>'
        print_ln ''
        print_ln '| `read_uhdm` | `read_systemverilog` | Test |'
        print_ln '|:-----------:|:--------------------:|:-----|'
        print_ln "${results_00[@]}" | sort
        print_ln "${results_10[@]}" | sort
        print_ln "${results_01[@]}" | sort
        print_ln ''
        print_ln '</details>'
    fi

    print_ln '<details>'
    print_ln '<summary><strong>List of passed tests</strong></summary>'
    print_ln ''
    print_ln '| `read_uhdm` | `read_systemverilog` | Test |'
    print_ln '|:-----------:|:--------------------:|:-----|'
    print_ln "${results_11[@]}" | sort
    print_ln ''
    print_ln '</details>'
} >> $GITHUB_STEP_SUMMARY
