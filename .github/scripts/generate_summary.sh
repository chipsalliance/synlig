#!/bin/bash
set -e -u -o pipefail
shopt -s nullglob
shopt -s extglob

declare -r SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
declare -r ROOT_DIR="$(realpath $SELF_DIR/../..)"

declare -r UHDM_RESULTS_FILE=$ROOT_DIR/test-results-uhdm.log
declare -r SV_RESULTS_FILE=$ROOT_DIR/test-results-systemverilog.log

#───────────────────────────────────────────────────────────────────────────────

function parse_stats() {
    local -n _test_names="$1"
    local -n _stats="$2"
    local -n _test_results="$3"
    local file="$4"

    while read test_result test_name; do
        [[ -z "$test_name" ]] && continue;

        _test_names[$test_name]=1

        _test_results[$test_name]="$test_result"

        if [[ "$test_result" == 1 ]]; then
            _stats[test_pass]=$(( ${_stats[test_pass]} + 1 ))
        else
            _stats[test_fail]=$(( ${_stats[test_fail]} + 1 ))
        fi
    done < $file
}

declare -A test_names=()

declare -A uhdm_test_results=()
declare -A uhdm_stats=(
    [test_fail]=0
    [test_pass]=0
)

declare -A sv_test_results=()
declare -A sv_stats=(
    [test_fail]=0
    [test_pass]=0
)

parse_stats test_names uhdm_stats uhdm_test_results $UHDM_RESULTS_FILE
parse_stats test_names sv_stats   sv_test_results   $SV_RESULTS_FILE

total_test_fail=$(( ${uhdm_stats[test_fail]} + ${sv_stats[test_fail]} ))
total_test_pass=$(( ${uhdm_stats[test_pass]} + ${sv_stats[test_pass]} ))

{
    printf '| Tool/Parser          | Failed | Passed |\n'
    printf '|:---------------------|-------:|-------:|\n'
    printf '| `read-uhdm`          | %d     | %d     |\n' "${uhdm_stats[test_fail]}" "${uhdm_stats[test_pass]}"
    printf '| `read-systemverilog` | %d     | %d     |\n' "${sv_stats[test_fail]}" "${sv_stats[test_pass]}"
    printf '| **Total**            | **%d** | **%d** |\n' "$total_test_fail" "$total_test_pass"
    printf '\n'
} >> $GITHUB_STEP_SUMMARY

failed_test_lines=()
passed_test_lines=()

declare -r pass_tag=':heavy_check_mark: PASS'
declare -r fail_tag=':x: FAIL'

for test_name in "${!test_names[@]}"; do
    uhdm_ok="${uhdm_test_results[$test_name]:-0}"
    sv_ok="${sv_test_results[$test_name]:-0}"

    (( uhdm_ok ))      && uhdm_result_tag="$pass_tag"      || uhdm_result_tag="$fail_tag"
    (( sv_ok ))        && sv_result_tag="$pass_tag"        || sv_result_tag="$fail_tag"

    # Puting digits for sorting purposes before "###". They will be removed after sorting.
    if (( !uhdm_ok || !sv_ok )); then
        failed_test_lines+=("${uhdm_ok}${sv_ok} ${test_name} ###| ${uhdm_result_tag} | ${sv_result_tag} | ${test_name} |")
    else
        passed_test_lines+=("${uhdm_ok}${sv_ok} ${test_name} ###| ${uhdm_result_tag} | ${sv_result_tag} | ${test_name} |")
    fi
done

print_ln() { (( $# )) && printf '%s\n' "$@" || : ; }

{
    if (( ${#failed_test_lines[@]} > 0 )); then
        print_ln '<details open>'
        print_ln '<summary><strong>List of failed tests</strong></summary><p>'
        print_ln ''
        print_ln '| `read_uhdm` | `read_systemverilog` | Test |'
        print_ln '|:-----------:|:--------------------:|:-----|'
        print_ln "${failed_test_lines[@]}" | sort | sed -e 's/^.*###//'
        print_ln ''
        print_ln '</p></details>'
    fi

    if (( ${#passed_test_lines[@]} > 0 )); then
        print_ln '<details>'
        print_ln '<summary><strong>List of passed tests</strong></summary><p>'
        print_ln ''
        print_ln '| `read_uhdm` | `read_systemverilog` | Test |'
        print_ln '|:-----------:|:--------------------:|:-----|'
        print_ln "${passed_test_lines[@]}" | sort | sed -e 's/^.*###//'
        print_ln ''
        print_ln '</p></details>'
    fi
} >> $GITHUB_STEP_SUMMARY
