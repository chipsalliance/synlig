#!/usr/bin/env python3

import json
import os
import sys
import re

result_descriptions = {
    "PASS": "Formally equivalent",
    "DIFF": "Formally not-equivalent",
    "NO GATE": "Both parsers didn't produce gate-level netlist",
    "S GATE": "Surelog parser didn't produce gate-level netlist",
    "Y GATE": "Yosys parser didn't produce gate-level netlist",
    "INCONCLUSIVE": "Inconclusive",
    "INCOM": "Incomplete, missing module declaration => Inconclusive",
    "UH PLUG": "UHDM Plugin error",
    "UH YGATE": "UHDM Plugin error + Yosys no gate",
    "MODEL_ER": "Error in model",
    "MODEL EM": "Model is empty",
    "SV2V_FAIL": "sv2v failed to convert test case",
    "RES_ERR" : "Result missing in test output, possibly error in model"
}
desc_max_len = len(max(result_descriptions.values(), key=len))
desc_max_key_len = len(max(result_descriptions.keys(), key=len))
header = (
        "|{: ^{key_len}} |{: ^6} |{: ^{desc_len}} |".format("Result",
                                                            "Count",
                                                            "Description",
                                                            key_len = desc_max_key_len,
                                                            desc_len = desc_max_len) +
        "\n|" + (desc_max_key_len+1) * "-" + "|" + 7 * "-" + "|" + (desc_max_len+1) * "-" + "|"
        )


def main():
    results_path = os.path.abspath(os.path.normpath(sys.argv[1]))
    result_files = []
    result_count = {}

    results = {}

    exit_code = 0
    for d in result_descriptions:
        # Initialize all results to ensure all are printed later
        result_count[d] = 0

    for root, dir, files in os.walk(results_path):
        for f in files:
            if f.endswith(".json"):
                result_files.append(os.path.join(root, f))

    for f in result_files:
        with open(f, "r") as file:
            result_data = json.load(file)
            if "result" not in result_data:
                result_data["result"] = "RES_ERR"
            results[result_data["name"]] = result_data["result"]


    failed_should_pass = []
    passed_should_fail = []
    with open("formal/passlist.txt", "r") as passlist:
        passlist_contents = passlist.read()

        for test in results.keys():
            if results[test] == "PASS":
                if not re.search("^" + test, passlist_contents, re.MULTILINE):
                    passed_should_fail.append(test)
            else: # Any other result is effectively FAIL
                if re.search("^" + test, passlist_contents, re.MULTILINE):
                    failed_should_pass.append(test)
            result_count[results[test]] += 1


    formatted_results = []
    for r in result_count:
        formatted_results.append([r, result_count[r], result_descriptions[r]])

    # Print in markdown to be compatible with Github summary
    print(header)
    for row in formatted_results:
        print("|{: >{key_len}} |{: >6} |{: <{desc_len}} |".format(*row, key_len = desc_max_key_len, desc_len = desc_max_len))

    if failed_should_pass:
        print("\n## Unexpected fail for tests:")
        for test in failed_should_pass:
            print(test)
        exit_code += 1
    if passed_should_fail:
        print("\n## Unexpected pass for tests:")
        for test in passed_should_fail:
            print(test)
        exit_code += 2


    exit(exit_code)

if __name__ == "__main__":
    main()
