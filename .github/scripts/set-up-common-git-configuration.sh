#!/bin/bash

begin_group() { printf '::group::%s\n' "$*"; }
end_group() { printf '::endgroup::\n'; }

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
