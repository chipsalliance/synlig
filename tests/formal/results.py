#!/usr/bin/env python3
import argparse
import json
import os
import sys
import re

from ansi_color import *

fv_result_descriptions = {
    "PASS":               "formally equivalent",
    "FAIL":               "formally not equivalent",
    "SKIP":               "not executed",
    "YOSYS_READ_FAIL":    "yosys couldn't read design",
    "PLUGIN_READ_FAIL":   "synlig couldn't read design",
    "EMPTY_MODULE":       "synlig or yosys produced empty module",
    "UNMATCHED_MODULE":   "different module names or count was produced",
    "NOTHING_TO_COMPARE": "there is nothing to compare in designs",
    "TIMEOUT":            "test timed out"
}

fv_desc_max_len = len(max(fv_result_descriptions.values(), key=len))
fv_desc_max_key_len = len(max(fv_result_descriptions.keys(), key=len))
fv_header = (
    "# Formal verification results\n" +
    "|{: ^{key_len}} | {: ^{header_len}} | {: ^{desc_len}} |".format(
        "Result", "Count", "Description",
        key_len = fv_desc_max_key_len,
        header_len = len("Count"),
        desc_len = fv_desc_max_len) +
    "\n|{results_sep}|{header_sep}|{desc_sep}|".format(
        results_sep = "-" * (fv_desc_max_key_len+1),
        header_sep = "-" * (len("Count") + 2),
        desc_sep = "-" * (fv_desc_max_len + 2)
    )
)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("tests_suite_name", type=str)
    parser.add_argument("performed_tests_list_file", type=str)
    args = parser.parse_args()

    # prepare performed tests summary
    preformed_tests_summary = {}
    with open(os.path.abspath(args.performed_tests_list_file)) as test_summary_file:
        performed_tests_summary = json.loads(test_summary_file.read())

    # prepare expected summary based on tests/formal/testlist.json
    # and find tests present in testlist that were not performed
    expected_tests_summary = {}
    with open("tests/formal/testlist.json", "r") as testlist_file:
        testlist_json = json.loads(testlist_file.read())

    not_performed_present_in_testlist = []
    for expected_result, reasons in testlist_json.items():
        for reason, groups in reasons.items():
            for group, group_content in groups.items():
                for name in group_content:
                    if performed_tests_summary.get(group + ":" + name) != None:
                        performed_tests_summary[group + ":" + name]["expected_result"] = expected_result
                    else:
                        if group == args.tests_suite_name:
                            not_performed_present_in_testlist.append(group + ":" + name)

    # search for tests that have different result then expected
    results_different_then_expected = []
    for test in performed_tests_summary.keys():
        if performed_tests_summary[test].get("expected_result") != None:
            expected_result = performed_tests_summary[test]["expected_result"]
            performed_result = performed_tests_summary[test]["result"]
            if expected_result != performed_result:
                if not (expected_result == "READ_FAIL" and performed_result in {"YOSYS_READ_FAIL", "PLUGIN_READ_FAIL"}):
                    results_different_then_expected.append((
                        test,
                        performed_result,
                        expected_result))

    # search for tests not present in testlist
    tests_not_present_in_expected_summary = []
    for test in performed_tests_summary.keys():
        if performed_tests_summary[test].get("expected_result") == None:
            tests_not_present_in_expected_summary.append((
                test,
                performed_tests_summary[test]["result"]))

    # prepare stats
    stats = {}
    for i in fv_result_descriptions:
        stats[i] = 0
    for test_result in performed_tests_summary.values():
        stats[test_result["result"]] += 1

    # print summary
    print("See formal verification flow diagram [README.md](https://github.com/chipsalliance/systemverilog-plugin/blob/main/tests/formal/README.md)")
    print(fv_header)

    for key in fv_result_descriptions:
        count = stats[key]
        desc = fv_result_descriptions[key]
        row_str = "|{: >{key_len}} |".format(key, key_len = fv_desc_max_key_len)
        row_str += " {: <{count_len}} |".format(str(count), count_len = len("Count"))
        row_str += " {: <{desc_len}} |".format(desc, desc_len = fv_desc_max_len)
        print(row_str)

    # print difference between performed and expected testlist

    exit_code = 0

    if len(results_different_then_expected) != 0:
        print("\nList of tests that result differ from expected:")
        for test_name, performed_result, expected_result in results_different_then_expected:
            print("%s resulted with: %s, but expected result was: %s %s" % (
                ansi_color(test_name, ANSI_BLUE),
                ansi_color(performed_result, ANSI_YELLOW),
                ansi_color(expected_result, ANSI_YELLOW),
                ansi_color("[ERROR]", ANSI_RED)))
            exit_code = 1

    if len(tests_not_present_in_expected_summary) != 0:
        print("\nList of tests that were not present in testlist.json:")
        for test_name, performed_result in tests_not_present_in_expected_summary:
            print("%s resulted with: %s" % (
                ansi_color(test_name, ANSI_BLUE),
                ansi_color(performed_result, ANSI_YELLOW)))
        exit_code = 1

    if len(not_performed_present_in_testlist) != 0:
        print("\nList of tests that were present in testlist.json but not performed:")
        for test_name in not_performed_present_in_testlist:
            print(ansi_color(test_name, ANSI_BLUE))
        exit_code = 1

    return exit_code

if __name__ == "__main__":
    exit(main())
