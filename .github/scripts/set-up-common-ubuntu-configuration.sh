#!/bin/bash
#-----------------------------------------------------------------------------
# Initial setup of a container image. This is called at the beginning of
# every job that uses Ubuntu container image.
#-----------------------------------------------------------------------------
set -e -u -o pipefail
shopt -s nullglob
shopt -s extglob

# Included only in CI, so `$0` should be relative to repository directory.
declare -r THIS_FILE="$0"

emit_error() { printf '::error file=%s::%s\n' "$THIS_FILE" "$*"; }
begin_group() { printf '::group::%s\n' "$*"; }
end_group() { printf '::endgroup::\n'; }

# Check whether the OS is compatible Ubuntu version.
(
	# https://www.freedesktop.org/software/systemd/man/os-release.html
	source /etc/os-release
	if ! [[ "${ID:-}" == 'ubuntu'
			&& ( "${VERSION_ID:-}" == '22.04' || "${VERSION_CODENAME:-}" == 'jammy' ) ]]; then
		emit_error "Incompatible OS (expected Ubuntu 22.04 AKA jammy), please update `${THIS_FILE}`."
		exit 1
	fi
)

#-----------------------------------------------------------------------------
begin_group 'Use regional (US) Ubuntu repository mirrors'
#-----------------------------------------------------------------------------

sources_list=/etc/apt/sources.list

declare -ra mirrors=(
	## US-central GCE mirror
	http://us-central1.gce.archive.ubuntu.com/ubuntu/
	## Official regional mirror
	http://us.archive.ubuntu.com/ubuntu/

	## Main official repository
	http://archive.ubuntu.com/ubuntu/
)
{
	printf 'deb %s jammy main restricted universe multiverse\n' "${mirrors[@]}"
	printf '\n'
	printf 'deb %s jammy-updates main restricted universe multiverse\n' "${mirrors[@]}"
	printf '\n'
	printf 'deb %s jammy-backports main restricted universe multiverse\n' "${mirrors[@]}"
	printf '\n'

	# Official security updates repo
	printf 'deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse\n'
} | tee "$sources_list"

end_group

#-----------------------------------------------------------------------------
begin_group 'Add extra APT configuration'
#-----------------------------------------------------------------------------

apt_ci_config=/etc/apt/apt.conf.d/99-ci

declare -rA ci_apt_conf=(
	# Enable parallel download from different mirrors.
	[Acquire::Queue-Mode]='host'

	# Adjust timeouts.
	[Acquire::Retries]='3'
	[Acquire::http::Timeout]='15'

	# Disables ipv6 (ubuntu servers have problems with it, and it is used by default).
	[Acquire::ForceIPv4]='true'
)
for k in "${!ci_apt_conf[@]}"; do
	printf '%s "%s";\n' "$k" "${ci_apt_conf[$k]//"/\\"}"
done | tee "$apt_ci_config"

end_group

#-----------------------------------------------------------------------------
begin_group 'Configure git'
#-----------------------------------------------------------------------------

# Use "some reasonable default" parallel fetch operations.
# https://git-scm.com/docs/git-config#Documentation/git-config.txt-fetchparallel
cat >> ~/.gitconfig <<-EOF
[fetch]
	parallel=0
EOF
# Github dropped support for unauthorized git:
# https://github.blog/2021-09-01-improving-git-protocol-security-github/
# Make sure we always use https:// instead of git://
cat >> ~/.gitconfig <<-EOF
[url "https://github.com/"]
	insteadOf=git://github.com/
EOF

end_group

#-----------------------------------------------------------------------------
