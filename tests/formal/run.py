#!/usr/bin/env python3
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time

from pathlib import Path

from ansi_color import *

repo_dir = Path(__file__).resolve().parent.parent.parent
sys.path.append(str(repo_dir / "tests" / "lib" / "python3"))

from run_command import run_command

def get_expected_result(listfile, full_test_name):
    test_group, test_name = full_test_name.split(":")

    with open(listfile, "r") as f:
        testlist = json.loads(f.read())

    for expected_result, reasons in testlist.items():
        for reason, groups in reasons.items():
            for group, group_content in groups.items():
                for name in group_content:
                    if test_group == group and test_name == name:
                        return expected_result

    return "NOT_FOUND"

def preprocess_sv2v(test_sources, work_path):
    """
    Converts all source files from test to Verilog with sv2v
    """

    sv2v_out = os.path.join(work_path, "sv2v.v")
    # Measurements show this normally takes up to 1 second.
    # sv2v allocates huge buffers and relies on overcommiting. No vmem limit as a result.
    result = run_command(
            ["sv2v", test_sources, f"-w={sv2v_out}"],
            timeout=30,
            capture_stderr=True,
            oom_score_adj=1000
        )
    print("|  " + str(result))

    if result.status != 0:
        return {"status": "fail"}

    return {"status": "converted", "file": sv2v_out}

def prepare_eqy_script(output_dir, script_name, plugin_file, yosys_file):

    script = [
        "[gold]",
        "tee -o %s/%s/yosys_ast.txt read_verilog -debug -sv %s" % (output_dir, script_name, yosys_file),
        "prep -flatten -auto-top",
        "opt",
        "",
        "[gate]",
        "tee -o %s/%s/plugin_ast.txt read_systemverilog -nocache -debug %s" % (output_dir, script_name, plugin_file),
        "prep -flatten -auto-top",
        "opt",
        "",
        "[strategy sby]",
        "use sby",
        "depth 2",
        "engine abc pdr"
    ]

    with open(script_name + ".eqy", 'w') as f:
        f.write('\n'.join(script))

def run_eqy(output_dir, script_name):

    result = run_command(
        ["eqy", script_name + ".eqy"],
        timeout=8*60,
        vmem_limit_kb=4*1024*1024,
        capture_stderr=True,
        oom_score_adj=500
    )
    print("|  " + str(result))

    if result.timed_out:
        return "TIMEOUT"

    equiv_patterns = {
        "Successfully proved designs equivalent":                                 "PASS",
        "read_gold: job failed. ERROR.":                                          "YOSYS_READ_FAIL",
        "read_gate: job failed. ERROR.":                                          "PLUGIN_READ_FAIL",
        "combine: ERROR: No \"gold\" top module found!":                          "EMPTY_MODULE",
        "combine: ERROR: No \"gate\" top module found!":                          "EMPTY_MODULE",
        "combine: ERROR: Unmatched module":                                       "UNMATCHED_MODULE",
        "combine: ERROR: Top modules of gold and gate do not have the same name": "UNMATCHED_MODULE",
        "partition: ERROR: No matched IDs for module":                            "NOTHING_TO_COMPARE"
    }

    with open(str(output_dir) + "/" + script_name + "/logfile.txt", "r") as eqy_out:
        log = eqy_out.read()

    for pattern in equiv_patterns.keys():
        if re.search(pattern, log):
            return equiv_patterns[pattern]

    return "SUSPECTED_PASS" if result.exit_status == 0 else "FAIL"

def log_result(result, output_dir):
    with open(os.path.join(output_dir, "result.json"), "w") as result_file:
        result_file.write(json.dumps(result))
        result_file.close()

def group_begin(name: str, skipped: bool = False):
    sys.stdout.flush()
    sys.stderr.flush()
    if skipped:
        label = ansi_color(name + " (skipped)", ANSI_YELLOW)
    else:
        label = ansi_color(name, ANSI_BLUE)
    if os.environ.get("GITHUB_ACTIONS") == "true":
        print(f"::group::{label}")
    else:
        print("# " + ansi_color(label, ANSI_YELLOW) + " #")


def group_end():
    sys.stdout.flush()
    sys.stderr.flush()
    if os.environ.get("GITHUB_ACTIONS") == "true":
        print("::endgroup::")
    else:
        print()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--test-id", type=int, default=-1,
            help="The test number. For status logging only.")
    parser.add_argument("--tests-count", type=int, default=-1,
            help="Total tests count. For status logging only.")

    parser.add_argument("--test-suite-name", type=str, default="",
            help="Used as a part of test name when performing lookup in skiplist. "
            + "Also used as a name of a directory created under output directory.")
    parser.add_argument("--test-suite-dir", type=Path, default=Path.cwd(),
            help="Base directory of the test suite. "
            + "The test file should be located in this directory tree.")

    parser.add_argument("--output-dir", type=Path, default=Path.cwd()/"build"/"tests")

    parser.add_argument("test_src_file", type=Path, help="(System)Verilog source file to test.")
    args = parser.parse_args()

    test_suite_dir = args.test_suite_dir.resolve()
    if not test_suite_dir.is_dir():
        print(f"Warning: Invalid Arguments: `test_suite_dir` ({args.test_suite_dir}) is not a directory. Using CWD ({Path.cwd()}) instead.")
        test_suite_dir = Path.cwd().resolve()

    test_src_file = args.test_src_file.resolve()

    if not test_src_file.exists():
        print(f"Error: Invalid Arguments: `test_src_file` ({args.test_src_file}) does not exist. Aborting.")
        sys.exit(1)

    # Test name presented to the user.
    try:
        # Path to the source file relative to the test suite directory.
        test_name = str(test_src_file.relative_to(test_suite_dir))
    except ValueError:
        print(f"Warning: Invalid Arguments: `test_src_file` ({test_src_file}) is not located below `test_suite_dir` ({test_suite_dir}).")
        # Use file path as specified in the argument.
        test_name = str(test_src_file)

    # Full test name presented to the user, with test suite name as a prefix.
    # This name is used in passlist.txt and skiplist.txt.
    if args.test_suite_name:
        full_test_name = f"{args.test_suite_name}:{test_name}"
    else:
        full_test_name = test_name

    # Test name suitable for use as a file name (no whitespace, `:`, `/`, control characters).
    safe_test_name = re.sub(r"[\s:/\x00-\x20\x7f-\x9f]", "_", test_name)

    # Directory for storing result.
    output_path = args.output_dir.resolve()

    expected_result = get_expected_result(repo_dir/"tests"/"formal"/"testlist.json", full_test_name)

    if args.test_suite_name:
        test_suite_work_dir = output_path/args.test_suite_name
    else:
        test_suite_work_dir = output_path

    try:
        test_suite_work_dir.mkdir(parents=True, exist_ok=True)
    except FileExistsError:
        print(f"Error: Output path (or its ancestor) exists and is not a directory: {test_suite_work_dir}")
        sys.exit(1)

    work_dir = test_suite_work_dir/safe_test_name
    test_result = {"test_name": test_name, "full_test_name": full_test_name}

    # Create new work directory, removing existing one if needed.
    if work_dir.is_dir():
        shutil.rmtree(work_dir)
    elif work_dir.exists():
        work_dir.unlink()
    work_dir.mkdir()

    os.chdir(work_dir)
    shutil.copyfile(test_src_file, str(work_dir) + "/" + os.path.basename(test_src_file))

    if expected_result == "SKIP":
        group_begin(full_test_name, True)
        group_end()
        test_result["result"] = expected_result
        log_result(test_result, work_dir)
        return 0

    group_begin(full_test_name)

    print("# Plugin v yosys")
    prepare_eqy_script(work_dir, "yosys", test_src_file, test_src_file)
    result = run_eqy(work_dir, "yosys")
    test_result["result_plugin_v_yosys"] = result
    print("|  result: " + color_result(result), end="\n|\n")

    ending_results = {"PASS",
        "PLUGIN_READ_FAIL",
        "EMPTY_MODULE",
        "UNMATCHED_MODULE",
        "NOTHING_TO_COMPARE",
        "SUSPECTED_PASS",
        "TIMEOUT"
        "FAIL"}

    if result in ending_results:
        test_result["result"] = result
        log_result(test_result, work_dir)
        group_end()
        return 0 if result == "PASS" else 1

    if result == "YOSYS_READ_FAIL":

        print("# Preprocess with sv2v")
        sv2v_result = preprocess_sv2v(test_src_file, work_dir)
        print("|  result: " + color_result(sv2v_result["status"]), end="\n|\n")

        if (sv2v_result["status"] == "fail"):
            test_result["result"] = "YOSYS_READ_FAIL"
            log_result(test_result, work_dir)
            group_end()
            return 1

        sv2v_file = sv2v_result["file"]

        print("# Plugin v sv2v yosys")
        prepare_eqy_script(work_dir, "sv2v_yosys", test_src_file, sv2v_file)
        result = run_eqy(work_dir, "sv2v_yosys")
        test_result["result_plugin_v_sv2v_yosys"] = result
        print("|  result: " + color_result(result), end="\n|\n")

        ending_results = {"PASS",
            "YOSYS_READ_FAIL",
            "PLUGIN_READ_FAIL",
            "EMPTY_MODULE",
            "UNMATCHED_MODULE",
            "NOTHING_TO_COMPARE",
            "SUSPECTED_PASS",
            "TIMEOUT"
            "FAIL"}

        if result in ending_results:
            test_result["result"] = result
            log_result(test_result, work_dir)
            group_end()
            return 0 if result == "PASS" else 1

    test_result["result"] = "FAIL"
    log_result(test_result, work_dir)
    group_end()
    return 1

if __name__ == "__main__":
    sys.exit(main())
