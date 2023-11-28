#!/usr/bin/env bash

# Patches any yosys-config scripts to replace the fixed build path with a relative one
# Inspired by https://github.com/YosysHQ/oss-cad-suite-build/blob/f41b9ae59c6afe323b41a069da48c3835f0846b0/scripts/package-linux.sh#L248

search_path="${1:-.}"

for yosysconfig in $(find "$search_path" -type f -name yosys-config); do
	echo "Fixing paths in" "$yosysconfig"

	patch -ns "$yosysconfig" << EOT
1a2
> install_prefix="\$(readlink -f "\$(dirname "\${BASH_SOURCE[0]}")/..")"
EOT

	# Get current fixed prefix that is already in the file
	old_prefix="$(readlink -f "$(dirname "$yosysconfig")/..")"

	sed -i "s,\"$old_prefix,\"\$install_prefix,g" "$yosysconfig"
	sed -i "s,'$old_prefix,\"\$install_prefix\"',g" "$yosysconfig"
	sed -i "s,$old_prefix,\"\$install_prefix\",g" "$yosysconfig"

done
