echo "|Name | Result|" > $GITHUB_STEP_SUMMARY
echo "|-----|-------|" >> $GITHUB_STEP_SUMMARY

ROOT_DIR=$(dirname $(dirname $(dirname "$0")))
TEST_CASES="$(cd UHDM-integration-tests && python list.py -d tests -s ibex swerv synthesis opentitan serv serv-minimal hello-uvm assignment-pattern Forever BitsCallOnType OneClass Continue AnonymousUnion FunctionOnDesignLevel ParameterUnpackedArray VoidFunction2Returns PatternStruct ImportedFunctionCallInModuleAndSubmodule VoidFunctionWithoutReturn cmake PutC OneThis CastInFunctionInGenBlock PatternType FunctionOutputArgument GetC ForkJoinTypes EnumFirstInInitial ImportFunction DpiChandle Disable EnumFirst TypedefOnFileLevel UnsizedConstantsParameterParsing Fork PatternInFunction TypedefVariableDimensions ParameterUnpackedLogicArray SelectFromUnpackedInFunction PatternReplication VoidFunction MultiplePrints BitSelectPartSelectInFunction ImportPackageWithFunction ParameterPackedArray StringAssignment SystemFunctions ParameterDoubleUnderscoreInSvFrontend OutputSizeWithParameterOfInstanceInitializedByStructMember ParameterOfSizeOfParametrizedPort ParameterOfSizeOfParametrizedPortInSubmodule ParameterOfSizeOfPort StringAssignConcatenation StringLocalParamInitByConcatenation StringWithBackslash FunctionWithOverriddenParameter RealValue BitsCallOnParametetrizedTypeFromPackage AssignToUnpackedUnionFieldAndReadOtherField IndexedPartSelectInFor NestedPatternPassedAsPort NestedStructArrayParameterInitializedByPatternPassedAsPort PartSelectInFor SelfSelectsInBitSelectAfterBitSelect StructArrayParameterInitializedByPatternPassedAsPort SelectGivenBySelectOnParameterInFunction StreamOperatorBitReverseFunction)"
TEST_CASES=$(echo $TEST_CASES | sed "s/[][,\"]//g") # Remove characters '[', ']', '"' and ',' from json like array

for TEST_CASE in $TEST_CASES;
do
    export TEST_CASE
    $ROOT_DIR/UHDM-integration-tests/.github/ci.sh
    if [ $? -eq 0 ]; then
        echo "|$TEST_CASE | :heavy_check_mark: **PASS**|" >> $GITHUB_STEP_SUMMARY
    else
        echo "|$TEST_CASE | :x: **FAIL**|" >> $GITHUB_STEP_SUMMARY
        export FAILED=1
    fi
done

# Leave with error status if any test failed
if [[ $FAILED -ne 0 ]]; then
    exit 1
fi
