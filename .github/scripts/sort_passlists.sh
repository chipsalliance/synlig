#!/usr/bin/env bash

set -e -u -o pipefail
shopt -s nullglob

declare -r SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
declare -r REPO_DIR=$SELF_DIR/../..
cd $REPO_DIR

files_to_sort_check=(
    formal/passlist.txt
    uhdm-tests/opentitan/opentitan_parsing_test/ot-cores-passlist.txt
)

for f in "${files_to_sort_check[@]}"; do
    LC_ALL=C.UTF-8 sort -f -u -o $f $f
done
