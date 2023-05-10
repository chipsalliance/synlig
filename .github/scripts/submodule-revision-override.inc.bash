# Defaults
declare -r yosys_f4pga_plugins_default_gh_user=antmicro
declare -r yosys_f4pga_plugins_default_gh_repo=yosys-f4pga-plugins
declare -r uhdm_tests_default_gh_user=antmicro
declare -r uhdm_tests_default_gh_repo=uhdm-integration


# parse-custom-branch-spec USER_OUT_VAR_NAME REPO_OUT_VAR_NAME BRANCH_OUT_VAR_NAME BRANCH_SPEC
#
# Parses Github revision (tree) URL passed in `BRANCH_SPEC` and writes
# user name, repo name, and revision, to respective variables passed in
# `*_OUT_VAR_NAME` arguments.
#
# The `BRANCH_SPEC` can skip `https://github.com` prefix, but has to keep `/` as
# a first character.
#
# Note: `*_OUT_VAR_NAME` shall not start with `_`.
parse-custom-branch-spec() {
	local -n _user_out="$1"
	local -n _repo_out="$2"
	local -n _branch_out="$3"
	local -r _branch_spec="$4"
	if [[ "$_branch_spec" =~ (https?://github.com)?/([^/]+)/([^/]+)/tree/(.+) ]]; then
		_user_out="${BASH_REMATCH[2]}"
		_repo_out="${BASH_REMATCH[3]}"
		_branch_out="${BASH_REMATCH[4]}"
	fi
}


# override-submodule-if-requested SUBMODULE_NAME DEFAULT_GH_USER DEFAULT_GH_REPO BRANCH_SPEC
#
# Parses Github revision (tree) URL or a revision passed in `BRANCH_SPEC` and
# switches `SUBMODULE_NAME` submodule to use that revision. If the `BRANCH_SPEC`
# contains just a revision, `DEFAULT_GH_USER` and `DEFAULT_GH_REPO` are used to
# locate that revision.
#
# The URL has to be in form:
#     https://github.com/<USER>/<REPO>/tree/<REVISION>
# or just:
#     /<USER>/<REPO>/tree/<REVISION>
# to be considered an URL.
#
# When `BRANCH_SPEC` is empty nothing is changed.
override-submodule-if-requested() {
	local -r submodule_name="$1"
	local -r default_gh_user="$2"
	local -r default_gh_repo="$3"
	local -r branch_spec="$4"

	local gh_user="$default_gh_user"
	local gh_repo="$default_gh_repo"
	local gh_branch="$branch_spec"

	# Parse Github branch URL and store respective values in passed `gh_*` variables.
	parse-custom-branch-spec \
			gh_user gh_repo gh_branch \
			"$branch_spec"

	printf '%s: %s\n' \
			'user	' "$gh_user" \
			'repo	' "$gh_repo" \
			'branch' "$gh_branch" \
			;

	cd "$submodule_name"
	git remote add custom "https://github.com/${gh_user}/${gh_repo}.git"
	git fetch custom "${gh_branch}"
	git checkout FETCH_HEAD
}
