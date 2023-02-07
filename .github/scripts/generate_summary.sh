ROOT_DIR=$(dirname $(dirname $(dirname "$0")))
TEST_RESULTS_PREFIX=$ROOT_DIR/test-results
UHDM_PASSED_FILE=$TEST_RESULTS_PREFIX-uhdm.passed
UHDM_FAILED_FILE=$TEST_RESULTS_PREFIX-uhdm.failed
SYSTEMVERILOG_PASSED_FILE=$TEST_RESULTS_PREFIX-systemverilog.passed
SYSTEMVERILOG_FAILED_FILE=$TEST_RESULTS_PREFIX-systemverilog.failed

# Read passed tests if any exist
if [[ -e $UHDM_PASSED_FILE ]]; then
    UHDM_PASSED_NUMBER=$(wc -l < $UHDM_PASSED_FILE)
else
    UHDM_FAILED_NUMBER=0
fi
if [[ -e $SYSTEMVERILOG_PASSED_FILE ]]; then
    SYSTEMVERILOG_PASSED_NUMBER=$(wc -l < $SYSTEMVERILOG_PASSED_FILE)
else
    SYSTEMVERILOG_PASSED_NUMBER=0
fi

# Read failed tests if any exist
if [[ -e $UHDM_FAILED_FILE ]]; then
    UHDM_FAILED_NUMBER=$(wc -l < $UHDM_FAILED_FILE)
else
    UHDM_FAILED_NUMBER=0
fi
if [[ -e $SYSTEMVERILOG_FAILED_FILE ]]; then
    SYSTEMVERILOG_FAILED_NUMBER=$(wc -l < $SYSTEMVERILOG_FAILED_FILE)
else
    SYSTEMVERILOG_FAILED_NUMBER=0
fi

TOTAL_FAILED_TESTS=$(($UHDM_FAILED_NUMBER+$SYSTEMVERILOG_FAILED_NUMBER))
TOTAL_PASSED_TESTS=$(($UHDM_PASSED_NUMBER+$SYSTEMVERILOG_PASSED_NUMBER))
TOTAL_TESTS=$(($TOTAL_FAILED_TESTS+$TOTAL_PASSED_TESTS))

if [[ ! -e $UHDM_FAILED_FILE && ! -e $SYSTEMVERILOG_FAILED_FILE ]]; then
    echo ":heavy_check_mark: ALL TESTS PASSED :heavy_check_mark:" > $GITHUB_STEP_SUMMARY
else
    echo ":x: SOME TESTS FAILED :x:" > $GITHUB_STEP_SUMMARY
fi
echo "" >> $GITHUB_STEP_SUMMARY
echo "| Name | Tests failed | Tests passed |" >> $GITHUB_STEP_SUMMARY
echo "|------|--------------|--------------|" >> $GITHUB_STEP_SUMMARY
echo "| tests-read-uhdm          | $UHDM_FAILED_NUMBER | $UHDM_PASSED_NUMBER |" >> $GITHUB_STEP_SUMMARY
echo "| tests-read-systemverilog | $SYSTEMVERILOG_FAILED_NUMBER | $SYSTEMVERILOG_PASSED_NUMBER |" >> $GITHUB_STEP_SUMMARY
echo "| **Total** | **$TOTAL_FAILED_TESTS** | **$TOTAL_PASSED_TESTS** |" >> $GITHUB_STEP_SUMMARY
echo "" >> $GITHUB_STEP_SUMMARY
echo "$TOTAL_FAILED_TESTS out of total $TOTAL_TESTS failed." >> $GITHUB_STEP_SUMMARY
echo "" >> $GITHUB_STEP_SUMMARY
echo "" >> $GITHUB_STEP_SUMMARY

echo "# Results for tests-read-uhdm:" >> $GITHUB_STEP_SUMMARY
echo "| Name | Result |" >> $GITHUB_STEP_SUMMARY
echo "|------|--------|" >> $GITHUB_STEP_SUMMARY
while IFS= read -r LINE; do
    echo "$LINE" >> $GITHUB_STEP_SUMMARY
done < $UHDM_FAILED_FILE
while IFS= read -r LINE; do
    echo "$LINE" >> $GITHUB_STEP_SUMMARY
done < $UHDM_PASSED_FILE
echo "" >> $GITHUB_STEP_SUMMARY

echo "# Results for tests-read-systemverilog:" >> $GITHUB_STEP_SUMMARY
echo "| Name | Result |" >> $GITHUB_STEP_SUMMARY
echo "|------|--------|" >> $GITHUB_STEP_SUMMARY
while IFS= read -r LINE; do
    echo "$LINE" >> $GITHUB_STEP_SUMMARY
done < $SYSTEMVERILOG_FAILED_FILE
while IFS= read -r LINE; do
    echo "$LINE" >> $GITHUB_STEP_SUMMARY
done < $SYSTEMVERILOG_PASSED_FILE
echo "" >> $GITHUB_STEP_SUMMARY
