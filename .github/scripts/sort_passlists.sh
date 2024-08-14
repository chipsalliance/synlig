#!/usr/bin/env bash

set -e -u -o pipefail
shopt -s nullglob

declare -r SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
declare -r REPO_DIR=$SELF_DIR/../..
cd $REPO_DIR

opentitan_passlist="tests/opentitan/opentitan_parsing_test/ot_cores_passlist.txt"
formal_testlist="tests/formal/testlist.json"

LC_ALL=C.UTF-8 sort -f -u -o $opentitan_passlist $opentitan_passlist

cat $formal_testlist | jq -s -c 'sort_by(.d) | .[]' |  python3 -m json.tool > ${formal_testlist}.tmp
mv ${formal_testlist}.tmp $formal_testlist
