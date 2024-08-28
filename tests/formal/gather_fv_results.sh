#!/bin/bash

declare -r SELF_DIR="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
declare -r REPO_DIR=$SELF_DIR/../..
cd $REPO_DIR

if [ -z "$1" ]; then
	echo "No test suite name provided"
	exit 1
fi

list_file="build/$1.performed_tests_list.json"

printf "{" > $list_file
for result_json in build/tests/${1}/*/result.json; do
	full_test_name=$(jq -r '.full_test_name' "${result_json}")
	printf '"%s": ' "${full_test_name}" >> "$list_file"
	cat ${result_json} >> $list_file
	printf "," >> $list_file
done
printf "}" >> $list_file
sed -s "s/},}/}}/g" -i $list_file

set -o pipefail
python3 ./tests/formal/results.py $list_file | tee "build/${NAME}_summary.txt"
