#!/bin/bash
set -e -o pipefail
shopt -s nullglob
shopt -s extglob

declare -r SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
declare -r ROOT_DIR="$(realpath $SELF_DIR/../..)"

declare -r UHDM_RESULTS_FILE=$ROOT_DIR/$2/$1-test-results-uhdm.log
declare -r SV_RESULTS_FILE=$ROOT_DIR/$2/$1-test-results-systemverilog.log

NO_UHDM_LOGS=0
NO_SV_LOGS=0

#--------------------------------------------------------------------------------

function parse_stats() {
    local -n _test_names="$1"
    local -n _stats="$2"
    local -n _test_results="$3"
    local -n _asan_results="$4"
    local file="$5"

    if [ ! -f $file ]; then
        if [ "$2" == "uhdm_stats" ]; then NO_UHDM_LOGS=1; fi
        if [ "$2" == "sv_stats" ]; then NO_SV_LOGS=1; fi
        return
    fi

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

if [ -n "$GITHUB_ACTIONS" ]; then
    printf "# Parsing tests for build: %s\n" $1
else
    printf "#/ Tests summary \#\n"
fi

if [ "$NO_UHDM_LOGS" == "1" ]; then printf "No read_uhdm logs detected!\n"; fi
if [ "$NO_SV_LOGS" == "1" ]; then printf "No read_systemverilog logs detected!\n"; fi

if [ "$1" == "asan" ]; then
    {
        printf '| Tool/Parser          | Failed | Passed | ASAN issues |\n'
        printf '|:---------------------|-------:|-------:|------------:|\n'
        printf '| `read-uhdm`          | %6d | %6d | %11d |\n' "${uhdm_stats[test_fail]}" "${uhdm_stats[test_pass]}" "${uhdm_stats[asan_fail]}"
        printf '| `read-systemverilog` | %6d | %6d | %11d |\n' "${sv_stats[test_fail]}" "${sv_stats[test_pass]}" "${sv_stats[asan_fail]}"
        printf '| **Total**            | %6d | %6d | %11d |\n' "$total_test_fail" "$total_test_pass" "$total_asan_fail"
        printf '\n'
    }
else
    {
        printf '| Tool/Parser          | Failed | Passed |\n'
        printf '|:---------------------|-------:|-------:|\n'
        printf '| `read-uhdm`          | %6d | %6d |\n' "${uhdm_stats[test_fail]}" "${uhdm_stats[test_pass]}"
        printf '| `read-systemverilog` | %6d | %6d |\n' "${sv_stats[test_fail]}" "${sv_stats[test_pass]}"
        printf '| **Total**            | %6d | %6d |\n' "$total_test_fail" "$total_test_pass"
        printf '\n'
    }
fi
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

    if [ "$NO_UHDM_LOGS" == "1" ]; then uhdm_ok=1; uhdm_asan_ok=1; fi
    if [ "$NO_SV_LOGS" == "1" ]; then sv_ok=1; sv_asan_ok=1; fi

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
        if [ -n "$GITHUB_ACTIONS" ]; then
            print_ln '<details open>'
            print_ln '<summary><strong>List of failed tests</strong></summary><p>'
        fi
        print_ln ''
        print_ln '| `read_uhdm` | `read_systemverilog` | Test |'
        print_ln '|:-----------:|:--------------------:|:-----|'
        print_ln "${failed_test_lines[@]}" | sort | sed -e 's/^.*###//'
        if [ -n "$GITHUB_ACTIONS" ]; then
            print_ln ''
            print_ln '</p></details>'
        fi
    fi

    if [ "$1" == "asan" ]; then
        if (( ${#asan_fail_lines[@]} > 0 )); then
            if [ -n "$GITHUB_ACTIONS" ]; then
                print_ln '<details open>'
                print_ln '<summary><strong>List of tests with ASAN issues</strong></summary><p>'
            fi
            print_ln ''
            print_ln '| `read_uhdm` | `read_systemverilog` | Test |'
            print_ln '|:-----------:|:--------------------:|:-----|'
            print_ln "${asan_fail_lines[@]}" | sort | sed -e 's/^.*###//'
            if [ -n "$GITHUB_ACTIONS" ]; then
                print_ln ''
                print_ln '</p></details>'
            fi
        fi
    fi
    if [ -n "$GITHUB_ACTIONS" ]; then
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
    fi
    print_ln ''
}
