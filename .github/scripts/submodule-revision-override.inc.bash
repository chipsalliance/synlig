# Defaults
declare -r surelog_default_gh_user=chipsalliance
declare -r surelog_default_gh_repo=Surelog


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


html-escape() {
	local v="$1"
	v="${v//&/\&amp;}"
	v="${v//</\&lt;}"
	v="${v//>/\&gt;}"
	v="${v//\"/\&quot;}"
	v="${v//\'/\&apos;}"
	printf '%s\n' "$v"
}


quot-escape() {
	local v="$1"
	v="${v//\\/\\\\}"
	v="${v//\"/\\\"}"
	v="${v//\'/\\\'}"
	printf '%s\n' "$v"
}


# Prints info inteded to be written to `$GITHUB_STEP_SUMMARY`. See main.yml.
emit-custom-branch-info-entry() {
	local -r submodule_name="$1"
	local -r default_gh_user="$2"
	local -r default_gh_repo="$3"
	local -r branch_spec="$4"

	local gh_branch=
	local gh_url=
	local gh_repo_url=
	local gh_rev=
	local override_str=

	if [[ -n "$branch_spec" ]]; then
		local gh_user="$default_gh_user"
		local gh_repo="$default_gh_repo"
		gh_branch="$branch_spec"
		# Parse Github branch URL name and store respective values in passed `gh_*` variables.
		# It does not touch the variables if the `branch_spec` is not an URL nor does start with `/`.
		parse-custom-branch-spec gh_user gh_repo gh_branch "$branch_spec"

		gh_repo_url="https://github.com/${gh_user}/${gh_repo}.git"
		# Query the repo and get branch's revision.
		gh_rev="$(git ls-remote -q "$gh_repo_url" "$gh_branch" 2>/dev/null | head -n1 | cut -f 1)"
		if [[ -z "$gh_rev" && "$gh_branch" =~ ^[0-9a-fA-F]{40}$ ]]; then
			# If the "branch" is not found in the repo and it looks like a revision hash, assume it is a revision hash.
			gh_rev="$gh_branch"
			gh_branch=''
		fi
		# URL to the revision Github page.
		gh_url="https://github.com/${gh_user}/${gh_repo}/tree/${gh_rev}"
		override_str=' (override)'
	else
		# No custom branch. For simplicity `gh_url` is left empty. It is not that useful in this case anyway.
		# Read submodule URL and revision.
		gh_repo_url="$(git config --file=.gitmodules submodule."$submodule_name".url)"
		gh_rev="$(git submodule status "$submodule_name" 2>/dev/null | cut -b 2-41)"
	fi

	local gh_info="<samp>${gh_rev}</samp>"
	if [[ -n "$gh_url" ]]; then
		gh_info="<a href='$(quot-escape "${gh_url}")'>${gh_info}</a>"
	fi
	if [[ -n "$gh_branch" ]]; then
		gh_info="${gh_info} (<samp>$(html-escape "${gh_branch}")</samp>)"
	fi
	printf '<dt>%s%s</dt><dd>%s<br><samp>%s</samp></dd>\n' \
			"$(html-escape "$submodule_name")" "$override_str" \
			"${gh_info}" \
			"$(html-escape "${gh_repo_url}")"
}


emit-custom-branch-info-begin() {
	printf '<dl>\n'
}


emit-custom-branch-info-end() {
	printf '</dl>\n'
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
