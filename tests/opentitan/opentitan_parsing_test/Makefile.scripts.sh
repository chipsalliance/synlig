#!/bin/bash
declare -r result_unknown='unknown'

declare -r result_test_pass='test-pass'
declare -r result_test_fail='test-fail'

declare -r result_depfail_skip='depfail-skip'
declare -r result_passlist_skip='passlist-skip'
declare -r result_skiplist_skip='skiplist-skip'

declare -r result_passlist_test_pass='passlist-test-pass'
declare -r result_passlist_test_fail='passlist-test-fail'

declare -riA result_is_pass_map=(
	[${result_unknown}]=0

	[${result_test_pass}]=1
	[${result_test_fail}]=0

	[${result_depfail_skip}]=0
	[${result_passlist_skip}]=1
	[${result_skiplist_skip}]=1

	[${result_passlist_test_pass}]=1
	[${result_passlist_test_fail}]=0
)

# Maps result to human-friendly name.
declare -rA map_result_to_pretty_str=(
	[${result_unknown}]='(unknown)'
	[${result_test_pass}]='PASS'
	[${result_test_fail}]='FAIL'
	[${result_depfail_skip}]='skip (dep fail)'
	[${result_passlist_skip}]='skip (passlist)'
	[${result_skiplist_skip}]='skip (skiplist)'
	[${result_passlist_test_pass}]='PASS (passlist)'
	[${result_passlist_test_fail}]='FAIL (passlist)'
)
# Maps result to two, space separated, CSI values.
declare -rA map_result_to_csi=(
	[${result_unknown}]='1;35 35'
	[${result_test_pass}]='32 1;92'
	[${result_test_fail}]='31 1;91'
	[${result_depfail_skip}]='2;33 93'
	[${result_passlist_skip}]='2;32 92'
	[${result_skiplist_skip}]='2;37 97'
	[${result_passlist_test_pass}]='32 1;92'
	[${result_passlist_test_fail}]='1;31 1;91'
)

# Maps result to Github's Markdown icon.
declare -rA map_result_to_md_icon=(
	[${result_unknown}]=':question:'
	[${result_test_pass}]=':green_heart:'
	[${result_test_fail}]=':x:'
	[${result_depfail_skip}]=':heavy_multiplication_x:'
	[${result_passlist_skip}]=':heavy_minus_sign:'
	[${result_skiplist_skip}]=':heavy_minus_sign:'
	[${result_passlist_test_pass}]=':heavy_check_mark:'
	[${result_passlist_test_fail}]=':no_entry:'
)


#───────────────────────────────────────────────────────────────────────────────
# Local helpers
#───────────────────────────────────────────────────────────────────────────────

_write_result() {
	printf '%s\n' "$1" > "${TARGET_RESULT_FILE}";
}

_logf_stderr_msg() {
	printf "$@" > ${MAKE_TERMERR:-/dev/stderr}
}

_get_core_result() {
	local core="$1"

	local result_file="$(get_core_result_file "$core")"
	local result=
	if [[ -e "$result_file" ]]; then
		read result < "$result_file"
	fi
	if ! [[ -n "$result" && -v result_is_pass_map["$result"] ]]; then
		result="$result_unknown"
	fi
	printf '%s' "$result"
}

_get_core_name() {
	local core="$1"

	local name_file="$(get_core_name_file "$core")"
	local name=
	if [[ -e "$name_file" ]]; then
		name=$(< "$name_file")
	fi
	printf '%s' "$name"
}

_get_available_mem_percent() {
	local -iA meminfo
	local k v
	while read -r k v; do
			meminfo[$k]="$v"
	done < <(sed -nre '/Mem(Total|Available)/ s/(\w+): *([0-9]+) .*/\1 \2/p' /proc/meminfo)
	if (( ${meminfo[MemAvailable]:-0} > 0 && ${meminfo[MemTotal]:-0} > 0 )); then
			local -i mem_usage=$(( 100 * meminfo[MemAvailable] / meminfo[MemTotal] )) || :
			echo "${mem_usage:-0}"
	else
			echo "0"
	fi
}

_process_core() {
	local _skip_condition="$1"
	local _skip_result="$2"
	local _pass_result="$3"
	local _fail_result="$4"

	local dep=
	local dep_result=

	local -i all_dep_results_are_pass=1
	local -i all_dep_results_are_pass_or_depfail=1

	for dep in "${TARGET_TEST_DEPS[@]}"; do
		dep_result="$(_get_core_result "$dep")"
		if ! (( ${result_is_pass_map["$dep_result"]} )); then
			all_dep_results_are_pass=0
			if [[ "$dep_result" != "${result_depfail_skip}" ]]; then
				all_dep_results_are_pass_or_depfail=0
				break
			fi
		fi
	done

	local -i do_skip=0
	case "$_skip_condition" in
		'all_deps_pass_or_depfail')
			do_skip=$(( all_dep_results_are_pass_or_depfail ))
		;;
		'all_deps_pass')
			do_skip=$(( all_dep_results_are_pass ))
		;;
		'any_dep_fails')
			do_skip=$(( ! all_dep_results_are_pass ))
		;;
	esac
	if (( do_skip )); then
		_write_result "${_skip_result}"
		return 0
	fi

	# Do not start until memory use falls below a threshold.
	# We don't want to start multiple memory-heavy jobs which could trigger
	# OOM kill.
	while (( $(_get_available_mem_percent) <= ${MIN_FREE_MEM_TO_START_TEST} )); do
		_logf_stderr_msg '\x1b[33;2mWaiting for more free memory (currently free: %d%%) before starting \x1b[22m%s\x1b[0m\n' \
				"$(_get_available_mem_percent)" \
				"$TARGET_CORE_NAME" \
				;
		sleep 10
	done


	_logf_stderr_msg '\x1b[37;2mStarting test: \x1b[22m%s\x1b[0m\n' "$TARGET_CORE_NAME"
	local -i rc=0
	(
		source ${VENV_DIR}/bin/activate
		cd ${OPENTITAN_DIR}

		# Fusesoc runs make, which normally would inherit settings from this
		# make. We don't want that, as it can cause failures from the make
		# itself.
		unset MAKE_TERMOUT
		unset MAKE_TERMERR
		unset MFLAGS
		unset MAKEFLAGS
		unset MAKELEVEL

		if [[ "$VMEM_LIMIT_KB" == +([0-9]) ]]; then
			ulimit -HS -v "$VMEM_LIMIT_KB"
		fi
		/usr/bin/time -v --quiet -o "$(get_core_fusesoc_stats_file "$TARGET_CORE")" \
			fusesoc --verbose --cores-root=. \
				run \
					--flag=fileset_ip \
					--flag=ot_is_custom_tiny \
					--target=default \
					--build \
					--tool=yosys \
					"$TARGET_CORE_NAME" \
				&> "$(get_core_fusesoc_log_file "$TARGET_CORE")"
	) || rc=$?  # Fusesoc exits with rc=0 after Ctrl+C, but with nice message in the log.
	if grep -qs ' FuseSoC aborted ' "$(get_core_fusesoc_log_file "$TARGET_CORE")"; then
		return 0
	fi

	if (( rc == 0 )); then
		_write_result "$_pass_result"
	else
		_write_result "$_fail_result"
	fi
	return 0
}

#───────────────────────────────────────────────────────────────────────────────
# Functions called from Makefile for generating results and running tests
#───────────────────────────────────────────────────────────────────────────────

process_skipped_core() {
	_write_result "${result_skiplist_skip}"
	return 0
}

process_passing_core() {
	_process_core \
			'all_deps_pass_or_depfail' \
			"${result_passlist_skip}" \
			"${result_passlist_test_pass}" \
			"${result_passlist_test_fail}"
}

process_tested_core() {
	_process_core \
			'any_dep_fails' \
			"${result_depfail_skip}" \
			"${result_test_pass}" \
			"${result_test_fail}"
}

process_top_down_tested_core() {
	_process_core \
			'all_deps_pass' \
			"${result_passlist_skip}" \
			"${result_test_pass}" \
			"${result_test_fail}"
}

#───────────────────────────────────────────────────────────────────────────────
# Status and results printing
#───────────────────────────────────────────────────────────────────────────────

_append_core_deps_to_list() {
	local -r core="$1"
	local -n out_list="$2"

	local dep

	local -a deps
	while read dep; do
		[[ -z "$dep" ]] && continue
		deps+=("$dep")
	done < $(get_core_deps_file "$core")

	local -A dep_names
	local -A dep_results
	for dep in "${deps[@]}"; do
		dep_names[$dep]="$(_get_core_name "$dep")"
		dep_results[$dep]="$(_get_core_result "$dep")"
	done

	if (( "${#out_list[@]}" > 0 )); then
		out_list+=('')
	fi
	out_list+=($'\x1b[0;39;1;3mDirectly blocked by:\x1b[0m')

	for dep in "${deps[@]}"; do
		local dep_result=${dep_results["$dep"]}
		local -i dep_passed=${result_is_pass_map["$dep_result"]}
		if (( ! dep_passed )) && [[ "$dep_result" != "${result_unknown}" ]]; then
			local dep_result_str="${map_result_to_pretty_str[$dep_result]}"
			local -a dep_csi=(${map_result_to_csi[$dep_result]})
			local line
			printf -v line '\x1b[2m- \x1b[0m%s (\x1b[%sm%s\x1b[0m)' "${dep_names[$dep]}" "${dep_csi[0]}" "${dep_result_str}"
			out_list+=("$line")
		fi
	done
}

_append_core_users_to_list() {
	local -r core="$1"
	local -n out_list="$2"

	local user

	local -a users=()
	while read user; do
		[[ -z "$user" ]] && continue
		users+=("${user}")
	done < $(get_core_users_file "$core")

	if (( ${#users[@]} == 0 )); then
		return
	fi

	local -A user_names
	for user in "${users[@]}"; do
		user_names["$user"]="$(_get_core_name "$user")"
	done

	if (( "${#out_list[@]}" > 0 )); then
		out_list+=('')
	fi
	out_list+=($'\x1b[0;39;1;3mDirectly blocking:\x1b[0m')

	for user in "${users[@]}"; do
		out_list+=($'\x1b[2m- \x1b[0m'"${user_names["$user"]}")
	done
}

_append_core_test_log_fragment_to_list() {
	local -r core="$1"
	local -n out_list="$2"

	local -r log_file="$(get_core_fusesoc_log_file "$core")"
	if [[ ! -e "$log_file" ]]; then
		return
	fi

	if (( ${#out_list[@]} > 0 )); then
		out_list+=('')
	fi
	local -ri lines_count=$(wc -l < "$log_file")
	local -r rel_log_file="${log_file#${THIS_SCRIPT_DIR}/}"

	out_list+=($'\x1b[0;39;1;3mFile: \x1b[39;1m'"$rel_log_file"$'\x1b[0m')

	if (( lines_count > ${LOG_DUMP_LINES_LIMIT} )); then
		out_list+=($'\x1b[2;3m... skipped '"$(( lines_count - ${LOG_DUMP_LINES_LIMIT} ))"$' lines ...\x1b[0m')
	fi
	out_list+=("$(tail -n ${LOG_DUMP_LINES_LIMIT} "$log_file")")
}

print_result() {
	local -r core="$1"
	local -r result="$(_get_core_result "$core")"
	local result_str="${map_result_to_pretty_str[$result]}"
	local -a csi=(${map_result_to_csi[$result]})
	local simple_result_str=
	local -a details=()

	if (( ${result_is_pass_map["$result"]} )); then
		simple_result_str=$'\x1b[1;92mPASS\x1b[0m'
	else
		simple_result_str=$'\x1b[1;91mFAIL\x1b[0m'
	fi

	case "$result" in
		${result_unknown})
			_append_core_deps_to_list "$core" details
			_append_core_users_to_list "$core" details
			_append_core_test_log_fragment_to_list "$core" details
		;;

		${result_test_pass})
		;;
		${result_test_fail})
			_append_core_users_to_list "$core" details
			_append_core_test_log_fragment_to_list "$core" details
		;;

		${result_depfail_skip})
			_append_core_deps_to_list "$core" details
			_append_core_users_to_list "$core" details
		;;
		${result_passlist_skip})
		;;
		${result_skiplist_skip})
		;;

		${result_passlist_test_pass})
		;;
		${result_passlist_test_fail})
			_append_core_users_to_list "$core" details
			_append_core_test_log_fragment_to_list "$core" details
		;;
	esac

	# `\x1b[2K\x1b[1G` erases the line and moves cursor to first column.
	# This way github can use `::group::` prefix, while normal terminal doesn't
	# print it because it is instantly erased.
	printf '::group::\x1b[2K\x1b[1G%s  \x1b[%sm%-16s\x1b[0m  \x1b[%sm%s\x1b[0m\n' \
			"$simple_result_str" \
			"${csi[0]}" "$result_str" \
			"${csi[1]}" "$(_get_core_name "$core")"
	if (( ${#details[@]} )); then
		printf '%s\n' "${details[@]}"
	fi
	printf '::endgroup::\x1b[2K\x1b[1G\n'
}

print_summary() {
	local core
	for core in "$@"; do
		print_result "$core"
	done
}

print_summary_md() {
	local core

	local -iA results_count=()
	local -ra all_results=(
		"${result_passlist_test_fail}"
		"${result_test_fail}"
		"${result_depfail_skip}"
		"${result_test_pass}"
		"${result_passlist_test_pass}"
		"${result_passlist_skip}"
		"${result_skiplist_skip}"
		"${result_unknown}"
	)

	local -A result_tests_map=()

	for core in "$@"; do
		local result="$(_get_core_result "$core")"

		results_count["$result"]=$(( ${results_count["$result"]:-0} + 1 ))
		result_tests_map["$result"]="${result_tests_map["$result"]:-} $core"
	done

	printf '| Result | Count |\n'
	printf '|:-------|------:|\n'

	local result
	local result_str=
	local -a csi=()
	for result in "${all_results[@]}"; do
		printf '| %s | %d |\n' "${map_result_to_pretty_str[$result]}" "${results_count[$result]:-0}"
	done

	local -a warnings=()

	# Emit warnings for situations causing a CI fail.
	if (( ${results_count[${result_test_pass}]:-0} > 0 )); then
		warnings+=("There are tests that pass but are not on the passlist. See *${map_result_to_pretty_str[$result_test_pass]}* below.")
	fi
	if (( ${results_count[${result_passlist_test_fail}]:-0} > 0 )); then
		warnings+=("Some tests from the passlist did fail. See *${map_result_to_pretty_str[$result_passlist_test_fail]}* below.")
	fi
	if (( ${results_count[${result_unknown}]:-0} > 0 )); then
		warnings+=("Some tests reported unknown status. See *${map_result_to_pretty_str[$result_unknown]}* below.")
	fi

	# Print warnings
	if (( ${#warnings[@]} > 0 )); then
		printf '\n---\n'
		printf '\n**WARNING**: %s\n' "${warnings[@]}"
		printf '\n---\n'
	fi

	local -rA section_details_attrs=(
		[${result_test_pass}]=' open'
		[${result_passlist_test_pass}]=''
		[${result_passlist_skip}]=''
		[${result_test_fail}]=' open'
		[${result_passlist_test_fail}]=' open'
		[${result_depfail_skip}]=''
		[${result_skiplist_skip}]=''
		[${result_unknown}]=' open'
	)

	local -riA print_users=(
		[${result_test_pass}]=0
		[${result_passlist_test_pass}]=0
		[${result_passlist_skip}]=0
		[${result_test_fail}]=1
		[${result_passlist_test_fail}]=1
		[${result_depfail_skip}]=0
		[${result_skiplist_skip}]=0
		[${result_unknown}]=1
	)

	for result in "${all_results[@]}"; do
		if (( ${results_count[$result]:-0} == 0 )); then
			continue
		fi

		local result_str="${map_result_to_pretty_str[$result]}"
		local -a csi=(${map_result_to_csi[$result]})
		local icon="${map_result_to_md_icon[$result]}"
		local details_open=

		local -a cores=(${result_tests_map[$result]})
		printf '\n<details%s><summary><strong>%s %s</strong></summary><p><ul>\n' \
				"${section_details_attrs["$result"]:-}" "$icon" "$result_str"

		if (( ${print_users[$result]:-0} )); then
			for core in "${cores[@]}"; do
				local name="$(_get_core_name "$core")"
				printf '  <li><details open><summary><samp>%s</samp></summary>\n' "$name"
				printf '    &emsp;<em>Directly used by:</em><ul>\n'
				local user
				while read user; do
					[[ -z "$user" ]] && continue

					local user_name="$(_get_core_name "$user")"
					printf '    <li><samp>%s</samp></li>\n' "$user_name"
				done < $(get_core_users_file "$core")

				printf '  </ul></details></li>\n'
			done
		else
			for core in "${cores[@]}"; do
				local name="$(_get_core_name "$core")"
				printf '  <li><samp>%s</samp></li>\n' "$name"
			done
		fi

		printf '</ul></p></details>'
	done
	echo
	return ${#warnings[@]}
}
