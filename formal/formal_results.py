#!/usr/bin/env python3

import json
import os
import sys
import re

synth_result_descriptions = {
    "SV2V_FAIL": "sv2v failed to convert test case",
    "FAIL": "Error in Yosys, possibly error in model",
    "OK": "Successful synthesis without formal verification",
    "SKIPPED": "Test was not run due to previous pass/error"
}
fv_result_descriptions = {
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
    "FAIL": "Error in Yosys, possibly error in model",
    "SKIPPED": "Test was not run due to previous pass or Yosys fail"
}
synth_result_keys = [
    "yosys",
    "sv2v_yosys",
]
fv_result_keys = [
    "surelog",
    "sv2v_surelog"
]
synth_headers = [
    "Yosys",
    "sv2v + Yosys"
]
fv_headers = [
    "SV plugin",
    "sv2v + SV plugin"
]
fv_desc_max_len = len(max(fv_result_descriptions.values(), key=len))
fv_desc_max_key_len = len(max(fv_result_descriptions.keys(), key=len))
synth_desc_max_len = len(max(synth_result_descriptions.values(), key=len))
synth_desc_max_key_len = len(max(synth_result_descriptions.keys(), key=len))

synth_header = (
    "# Synthesis results\n" +
    "|{: ^{key_len}} | {: ^{header1_len}} | {: ^{header2_len}} | {: ^{desc_len}} |".format(
        "Result", synth_headers[0], synth_headers[1], "Description",
        key_len = synth_desc_max_key_len,
        header1_len = len(synth_headers[0]),
        header2_len = len(synth_headers[1]),
        desc_len = synth_desc_max_len) +
    "\n|{results_sep}|{header1_sep}|{header2_sep}|{desc_sep}|".format(
        results_sep = "-" * (synth_desc_max_key_len + 1),
        header1_sep = "-" * (len(synth_headers[0]) + 2),
        header2_sep = "-" * (len(synth_headers[1]) + 2),
        desc_sep = "-" * (synth_desc_max_len + 2)
    )
)
fv_header = (
    "# Formal verification results\n" +
    "|{: ^{key_len}} | {: ^{header1_len}} | {: ^{header2_len}} | {: ^{desc_len}} |".format(
        "Result", fv_headers[0], fv_headers[1], "Description",
        key_len = fv_desc_max_key_len,
        header1_len = len(fv_headers[0]),
        header2_len = len(fv_headers[1]),
        desc_len = fv_desc_max_len) +
    "\n|{results_sep}|{header1_sep}|{header2_sep}|{desc_sep}|".format(
        results_sep = "-" * (fv_desc_max_key_len+1),
        header1_sep = "-" * (len(fv_headers[0]) + 2),
        header2_sep = "-" * (len(fv_headers[1]) + 2),
        desc_sep = "-" * (fv_desc_max_len + 2)
    )
)


def process_data(results_path, result_keys: list, result_description_keys: list):
    result_files = []
    result_count = {}

    results = {}

    for d in result_description_keys:
        # Initialize all results to ensure all are printed later
        result_count[d] = {}
        for r in result_keys:
            result_count[d][r] = 0

    for root, dir, files in os.walk(results_path):
        for f in files:
            if f.endswith(".json"):
                result_files.append(os.path.join(root, f))

    for f in result_files:
        with open(f, "r") as file:
            result_data = json.load(file)
            results[result_data["name"]] = {}
            for result in result_keys:
                results[result_data["name"]][result] = result_data[result]

    failed_should_pass = []
    passed_should_fail = []
    with open("formal/passlist.txt", "r") as passlist:
        passlist_contents = passlist.read()

        for test in results.keys():
            for r in result_keys:
                result_count[results[test][r]][r] += 1

            if (results[test]["yosys"] == "OK" and results[test]["surelog"] == "PASS") or \
               (results[test]["sv2v_yosys"] == "OK" and results[test]["sv2v_surelog"] == "PASS"):
                if not re.search("^" + test, passlist_contents, re.MULTILINE):
                    passed_should_fail.append(test)
            else: # Any other result is effectively FAIL
                if re.search("^" + test, passlist_contents, re.MULTILINE):
                    failed_should_pass.append(test)

    return result_count, passed_should_fail, failed_should_pass


def print_results(headers, result_keys, result_descriptions, result_count, passed_should_fail, failed_should_pass, print_unexpected=False):
    desc_max_len = len(max(result_descriptions.values(), key=len))
    desc_max_key_len = len(max(result_descriptions.keys(), key=len))
    formatted_results = []
    exit_code = 0

    for row in result_count:
        if not row in result_descriptions:
            continue
        res = [row]
        for r in result_keys:
            res.append(result_count[row][r])
        res.append(result_descriptions[row])
        formatted_results.append(res)

    # Print in markdown to be compatible with Github summary
    for row in formatted_results:
        row_str = "|{: >{key_len}} |".format(row[0], key_len = desc_max_key_len)
        for i in range(len(result_keys)):
            row_str += " {: >{result_len}} |".format(row[i+1], result_len = len(headers[i]))
        row_str += " {: <{desc_len}} |".format(row[-1], desc_len = desc_max_len)
        print(row_str)

    if print_unexpected:
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

    return exit_code


def main():
    results_path = os.path.abspath(os.path.normpath(sys.argv[1]))

    # Get formal verification results descriptions
    result_description_keys = fv_result_descriptions.copy()
    # Merge it with synthesis results descriptions while overwriting same keys
    result_description_keys.update(synth_result_descriptions)
    # Extract description keys
    result_description_keys = list(result_description_keys.keys())
    # Merge all result keys
    result_keys = synth_result_keys + fv_result_keys

    result_count, passed_should_fail, failed_should_pass = \
        process_data(results_path, result_keys, result_description_keys)

    print(synth_header)
    print_results(synth_headers, synth_result_keys, synth_result_descriptions, result_count, passed_should_fail, failed_should_pass)

    print(fv_header)
    exit_code = print_results(fv_headers, fv_result_keys, fv_result_descriptions, result_count, passed_should_fail, failed_should_pass, True)

    exit(exit_code)

if __name__ == "__main__":
    main()
