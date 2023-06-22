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
    local -n _asan_results="$4"
    local file="$5"

    while read test_result asan_result test_name; do
        [[ -z "$test_name" ]] && continue;

        _test_names[$test_name]=1

        _asan_results[$test_name]="$asan_result"
        _test_results[$test_name]="$test_result"

        if [[ "$test_result" == 1 ]]; then
            _stats[test_pass]=$(( ${_stats[test_pass]} + 1 ))
        else
            _stats[test_fail]=$(( ${_stats[test_fail]} + 1 ))
        fi
        [[ "$asan_result" == 1 ]] || _stats[asan_fail]=$(( ${_stats[asan_fail]} + 1 ))
    done < $file
}

declare -A test_names=()

declare -A uhdm_test_results=()
declare -A uhdm_asan_results=()
declare -A uhdm_stats=(
    [test_fail]=0
    [test_pass]=0
    [asan_fail]=0
)

declare -A sv_test_results=()
declare -A sv_asan_results=()
declare -A sv_stats=(
    [test_fail]=0
    [test_pass]=0
    [asan_fail]=0
)

parse_stats test_names uhdm_stats uhdm_test_results uhdm_asan_results $UHDM_RESULTS_FILE
parse_stats test_names sv_stats   sv_test_results   sv_asan_results   $SV_RESULTS_FILE

total_test_fail=$(( ${uhdm_stats[test_fail]} + ${sv_stats[test_fail]} ))
total_test_pass=$(( ${uhdm_stats[test_pass]} + ${sv_stats[test_pass]} ))
total_asan_fail=$(( ${uhdm_stats[asan_fail]} + ${sv_stats[asan_fail]} ))

{
    printf '| Tool/Parser          | Failed | Passed | ASAN issues |\n'
    printf '|:---------------------|-------:|-------:|------------:|\n'
    printf '| `read-uhdm`          | %d     | %d     | %d          |\n' "${uhdm_stats[test_fail]}" "${uhdm_stats[test_pass]}" "${uhdm_stats[asan_fail]}"
    printf '| `read-systemverilog` | %d     | %d     | %d          |\n' "${sv_stats[test_fail]}" "${sv_stats[test_pass]}" "${sv_stats[asan_fail]}"
    printf '| **Total**            | **%d** | **%d** | **%d**      |\n' "$total_test_fail" "$total_test_pass" "$total_asan_fail"
    printf '\n'
} >> $GITHUB_STEP_SUMMARY

failed_test_lines=()
passed_test_lines=()
asan_fail_lines=()

declare -r pass_tag=':heavy_check_mark: PASS'
declare -r fail_tag=':x: FAIL'

for test_name in "${!test_names[@]}"; do
    uhdm_ok="${uhdm_test_results[$test_name]:-0}"
    uhdm_asan_ok="${uhdm_asan_results[$test_name]:-0}"
    sv_ok="${sv_test_results[$test_name]:-0}"
    sv_asan_ok="${sv_asan_results[$test_name]:-0}"

    (( uhdm_ok ))      && uhdm_result_tag="$pass_tag"      || uhdm_result_tag="$fail_tag"
    (( uhdm_asan_ok )) && uhdm_asan_result_tag="$pass_tag" || uhdm_asan_result_tag="$fail_tag"
    (( sv_ok ))        && sv_result_tag="$pass_tag"        || sv_result_tag="$fail_tag"
    (( sv_asan_ok ))   && sv_asan_result_tag="$pass_tag"   || sv_asan_result_tag="$fail_tag"

    # Puting digits for sorting purposes before "###". They will be removed after sorting.
    if (( !uhdm_ok || !sv_ok )); then
        failed_test_lines+=("${uhdm_ok}${sv_ok} ${test_name} ###| ${uhdm_result_tag} | ${sv_result_tag} | ${test_name} |")
    else
        passed_test_lines+=("${uhdm_ok}${sv_ok} ${test_name} ###| ${uhdm_result_tag} | ${sv_result_tag} | ${test_name} |")
    fi
    if (( !uhdm_asan_ok || !sv_asan_ok )); then
        asan_fail_lines+=("${uhdm_asan_ok}${sv_asan_ok} ${test_name} ###| ${uhdm_asan_result_tag} | ${sv_asan_result_tag} | ${test_name} |")
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

    if (( ${#asan_fail_lines[@]} > 0 )); then
        print_ln '<details open>'
        print_ln '<summary><strong>List of tests with ASAN issues</strong></summary><p>'
        print_ln ''
        print_ln '| `read_uhdm` | `read_systemverilog` | Test |'
        print_ln '|:-----------:|:--------------------:|:-----|'
        print_ln "${asan_fail_lines[@]}" | sort | sed -e 's/^.*###//'
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
