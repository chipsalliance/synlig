#!/bin/bash
set -e -u -o pipefail
shopt -s nullglob
shopt -s extglob
shopt -s globstar

declare -r SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
declare -r REPO_DIR="$SELF_DIR"

export PATH=$REPO_DIR/image/bin:$PATH

testsuite=$(realpath $1)
testsuite_name="${2:-}"

cd $REPO_DIR
v_files=( $testsuite/*/**/*.{v,sv} )
declare -i v_file_id=1
for v_file in "${v_files[@]}"; do

	python3 ./formal_verification.py \
			--test-id="$v_file_id" \
			--tests-count="${#v_files[@]}" \
			--test-suite-name="$testsuite_name" \
			--test-suite-dir="$testsuite" \
			"$v_file" \
			|| :

	v_file_id=$((v_file_id+1))
done
