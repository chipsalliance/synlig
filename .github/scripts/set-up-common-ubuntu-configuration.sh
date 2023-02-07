#!/bin/bash
#-----------------------------------------------------------------------------
# Initial setup of a container image. This is called at the beginning of
# every job that uses Ubuntu container image.
#-----------------------------------------------------------------------------
set -e -u -o pipefail
shopt -s nullglob
shopt -s extglob

begin_group() { printf '::group::%s\n' "$*"; }
end_group() { printf '::endgroup::\n'; }

#-----------------------------------------------------------------------------
begin_group 'Use regional (US) Ubuntu repository mirrors'
#-----------------------------------------------------------------------------

sources_list=/etc/apt/sources.list

declare -ra mirrors=(
	## Official regional mirror
	http://us.archive.ubuntu.com/ubuntu/

	# The 4 non-ubuntu URLs below were picked because they have highest
	# throughput from all official US mirrors (20+ Gbps) according
	# to https://launchpad.net/ubuntu/+archivemirrors.

	## US, 100 Gbps; https://launchpad.net/ubuntu/+mirror/enzu.com
	http://mirror.enzu.com/ubuntu/
	## US, 20 Gbps; https://launchpad.net/ubuntu/+mirror/mirror.genesisadaptive.com-archive
	http://mirror.genesisadaptive.com/ubuntu/
	## US, 20 Gbps; https://launchpad.net/ubuntu/+mirror/mirror.math.princeton.edu-archive
	http://mirror.math.princeton.edu/pub/ubuntu/
	## US, 20 Gbps; https://launchpad.net/ubuntu/+mirror/mirror.pit.teraswitch.com-archive
	http://mirror.pit.teraswitch.com/ubuntu/

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

# Set retry count to 6, and disables ipv6 (ubuntu servers have problems with
# it, and it is used by default).
printf '%s\n' \
		'Acquire::ForceIPv4 "true";' \
		'Acquire::Retries "6";' \
		| tee "$apt_ci_config"

end_group

#-----------------------------------------------------------------------------
