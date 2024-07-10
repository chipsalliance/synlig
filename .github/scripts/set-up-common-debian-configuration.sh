#!/bin/bash
#-----------------------------------------------------------------------------
# Initial setup of a container image. This is called at the beginning of
# every job that uses Debian container image.
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
	if ! [[ "${ID:-}" == 'debian'
			&& ( "${VERSION_ID:-}" == '12' || "${VERSION_CODENAME:-}" == 'bookworm' ) ]]; then
		emit_error "Incompatible OS (expected Debian 12 AKA bookworm), please update `${THIS_FILE}`."
		exit 1
	fi
)

#-----------------------------------------------------------------------------
begin_group 'Use regional (US) Debian repository mirrors'
#-----------------------------------------------------------------------------

sources_list=/etc/apt/sources.list.d/debian.sources

declare -ra mirrors=(
	## Official regional mirror
    http://ftp.us.debian.org/debian/
)
{
    printf "Types: deb\n"
    printf "URIs: %s\n" "${mirrors[@]}"
    printf "Suites: bookworm bookworm-updates\n"
    printf "Components: main\n"
    printf "Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg\n"
	printf '\n'
} | tee -a "$sources_list"

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

	# Disables ipv6 (servers have problems with it, and it is used by default).
	[Acquire::ForceIPv4]='true'
)
for k in "${!ci_apt_conf[@]}"; do
	printf '%s "%s";\n' "$k" "${ci_apt_conf[$k]//"/\\"}"
done | tee "$apt_ci_config"

end_group
