#!/bin/bash
ROOT_DIR=$(dirname $(dirname $(dirname "$0")))
if [[ -z $TESTS_TO_SKIP ]]; then
    TEST_CASES="$(cd UHDM-integration-tests && python list.py -d tests)"
else
    TEST_CASES="$(cd UHDM-integration-tests && python list.py -d tests -s $TESTS_TO_SKIP)"
fi
TEST_CASES=$(echo $TEST_CASES | sed "s/[][,\"]//g") # Remove characters '[', ']', '"' and ',' from json like array

LOG_DIR=$ROOT_DIR/logs

mkdir -p $LOG_DIR

mkdir -p $ROOT_DIR/test-results
for TEST_CASE in $TEST_CASES;
do
    export TEST_CASE
    mkdir -p $LOG_DIR/$TEST_CASE
    ROOT_DIR_ABSOLUTE=$(realpath $ROOT_DIR)/
    $ROOT_DIR/UHDM-integration-tests/.github/ci.sh | sed -e 's#'${ROOT_DIR_ABSOLUTE}'##g' | sed -e 's/\(End of script\).*//' | sed -e 's/\(Time spent\).*//' | tee $LOG_DIR/$TEST_CASE/ast.log
    TEST_RET=$?
    TEST_CASE="${TEST_CASE//tests\//}"
    if [[ $TEST_RET -eq 0 ]]; then
        printf '%s\t%s\n' "$TEST_CASE" '1' >> $ROOT_DIR/test-results/test-results.passed
    else
        printf '%s\t%s\n' "$TEST_CASE" '0' >> $ROOT_DIR/test-results/test-results.failed
        RET=1
    fi
done

# Leave with non-zero error status if any test failed
if [[ $RET -ne 0 ]]; then
    exit 1
fi
