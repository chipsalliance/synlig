#!/usr/bin/env python3
import argparse
import re
import os
import sys
import json
import shutil
import subprocess
from pathlib import Path

import time


def timed_subprocess_run(*run_args, **run_kwargs):
    ts = time.time()
    process = subprocess.run(*run_args, **run_kwargs)
    td = time.time() - ts
    return (process, td)


def get_skiplist(listfile):
    """
    Gets a list of tests to be skipped
    """
    entries = set()
    with open(listfile, "r") as f:
        for line in f:
            line = line.strip()
            if not line.startswith("#"):
                entries.add(line)

    return entries


def get_test_top_module(work_path, prefix=""):
    """
    Extracts top module name from Surelog output
    """

    log = []
    with open(os.path.join(work_path, "%ssurelog.out" % prefix), "r") as surelog_out:
        log = surelog_out.readlines()
        surelog_out.close()

    for line in log:
        if line.startswith("Top module:"):
            return line.split("\\")[-1]


def get_time_result(stderr_str):
    """
    Extracts resource usage from GNU time output
    """

    m1 = re.search(
        "([0-9\.:]+)user [0-9\.:]+system ([0-9]+):([0-9\.]+)elapsed ([0-9]+)%CPU",
        stderr_str,
    ).groups()
    m2 = re.search("([0-9]+)maxresident", stderr_str).groups()

    result = {
        "user": float(m1[0]),
        "elapsed": (int(m1[1]) * 60) + float(m1[2]),
        "cpu": int(m1[3]),
        "resident": int(m2[0]) / 1024,
    }
    return result


def make_timeout_cmd(timeout_s: int, kill_after_s: int = 10):
    return ['timeout', '-k', str(kill_after_s), str(timeout_s) + 's']


def preprocess_sv2v(test_sources, work_path):
    """
    Converts all source files from test to Verilog with sv2v
    """

    sv2v_out = os.path.join(work_path, "sv2v.v")
    # Measurements show this normally takes up to 1 second.
    process, duration = timed_subprocess_run([*make_timeout_cmd(30), "sv2v", test_sources, "-w=%s" % sv2v_out],
        capture_output=True,
        text=True,
    )
    print(f"# preprocess_sv2v: {duration:7.3f} s; rc: {process.returncode}")
    if process.stderr:
        for line in process.stderr.splitlines():
            print(f"[sv2v] {line}")
    if process.returncode != 0:
        return None

    return sv2v_out


def find_xilinx_cells():
    """
    Returns a path of Xilinx techlibs for default Yosys installation
    """

    yosys_bin_path = shutil.which("yosys")
    head_tail = os.path.split(yosys_bin_path)
    cells_path = os.path.join(head_tail[0], "..", "share", "yosys", "xilinx")
    return cells_path


def postprocess_gate_v(gate_v_path):
    """
    Normalizes `*_gate.v` file by removing non-important details
    and initializing registers to 0.
    """
    gate_v_path = Path(gate_v_path)
    if not (gate_v_path.exists() and gate_v_path.is_file()):
        return None

    # Each alternate pattern is inside its own group.
    # The replace() function below checks which group has been matched
    # and returns adequate replacement string.
    # If you need to change this, avoid using nested capturing groups.
    # Non capturing groups are OK though.
    PATTERNS = re.compile(
            r"(\b1'hx\b)|" +
            r"( *\(\* src = \"[a-zA-Z0-9_/|:\.-]*\" \*\)\s*)|" +
            r"( *\(\* keep = +1 +\*\)\s*)")

    def replace(match):
        if match.group(1):
            return "1'h0"
        elif match.group(2) or match.group(3):
            return ""
        raise Exception(f"Unexpected match: {match.group(0)!r}")

    content = None
    with open(gate_v_path, "r") as f:
        content = f.read()
    # Keep original file for debugging purposes.
    gate_v_path.rename(gate_v_path.with_suffix(".v.orig"))

    content = PATTERNS.sub(replace, content)

    with open(gate_v_path, "w") as f:
        f.write(content)


def run_surelog(test_path, output_dir, prefix=""):
    """
    Writes and executes Surelog synthesis script
    """

    gate_v = Path(output_dir) / f"{prefix}surelog_gate.v"
    script = [
        "plugin -i systemverilog",
        "tee -o %s/%ssurelog_ast.txt read_systemverilog -dump_ast1 -mutestdout %s" % (output_dir, prefix, test_path),
        "synth_xilinx",
        "write_verilog %s/%ssurelog_gate.v" % (output_dir, prefix),
    ]

    script_path = os.path.join(output_dir, "%ssurelog.ys" % prefix)

    with open(script_path, "w") as script_file:
        script_file.write("\n".join(script))
        script_file.close()

    # Measurements show this normally takes up to 350 seconds.
    process, duration = timed_subprocess_run(
        [*make_timeout_cmd(10*60), "yosys", "-s", script_path, "-q", "-q", "-l", "%s/%ssurelog.out" % (output_dir, prefix)],
        capture_output=True,
        text=True,
    )
    print(f"# run_surelog: {duration:7.3f} s; rc: {process.returncode}")
    if process.stderr:
        for line in process.stderr.splitlines():
            print(f"[yosys] {line}")

    postprocess_gate_v(os.path.join(output_dir, f"{prefix}surelog_gate.v"))

    return process.returncode


def run_yosys(test_path, output_dir, prefix=""):
    """
    Writes and executes Yosys synthesis script
    """

    script = [
        "tee -o %s/%syosys_ast.txt read_verilog -dump_ast1 -sv %s" % (output_dir, prefix, test_path),
        "synth_xilinx",
        "write_verilog %s/%syosys_gate.v" % (output_dir, prefix),
    ]

    script_path = os.path.join(output_dir, "%syosys.ys" % prefix)

    with open(script_path, "w") as script_file:
        script_file.write("\n".join(script))
        script_file.close()

    # Measurements show this normally takes up to 132 seconds.
    process, duration = timed_subprocess_run(
        [*make_timeout_cmd(5*60), "yosys", "-s", script_path, "-q", "-q", "-l", "%s/%syosys.out" % (output_dir, prefix)],
        capture_output=True,
        text=True,
    )
    print(f"# run_yosys: {duration:7.3f} s; rc: {process.returncode}")
    if process.stderr:
        for line in process.stderr.splitlines():
            print(f"[yosys] {line}")

    postprocess_gate_v(os.path.join(output_dir, f"{prefix}yosys_gate.v"))

    return process.returncode


def run_equiv(top_module, output_dir, surelog_gate="surelog_gate.v", yosys_gate="yosys_gate.v"):
    """
    Writes and executes Yosys equivalence check script
    """

    prefix = "sv2v_" if surelog_gate.startswith("sv2v_") else ""
    equiv_out = Path(output_dir) / f"{prefix}equiv.out"

    # Report equivalence without running actual check when both netlists
    # have the same contents. Otherwise Yosys can report inequivalence just
    # because it is unable to prove something.
    with open(surelog_gate, "r") as sgf, open(yosys_gate, "r") as ygf:
        surelog_gate_content = sgf.read()
        yosys_gate_content = ygf.read()
        if surelog_gate_content == yosys_gate_content:
            with open(equiv_out, "w") as outf:
                print(f"# run_equiv: netlist contents equal, skipping actual equivalence check.")
                # The string written below is checked by `get_equiv_result()`
                outf.write("Same content")
                return None

    cells_path = find_xilinx_cells()
    cells = [
        os.path.join(cells_path, "cells_sim.v"),
        os.path.join(cells_path, "cells_xtra.v"),
    ]

    script = [
        "read_verilog -sv %s/%s %s %s" % (output_dir, surelog_gate, cells[0], cells[1]),
        "prep -flatten -top %s" % top_module,
        "splitnets -ports;;",
        "design -stash surelog",
        "read_verilog -sv %s/%s %s %s" % (output_dir, yosys_gate, cells[0], cells[1]),
        "splitnets -ports;;",
        "prep -flatten -top %s" % top_module,
        "design -stash yosys",
        "design -copy-from surelog -as surelog %s" % top_module,
        "design -copy-from yosys -as yosys %s" % top_module,
        "equiv_make surelog yosys equiv",
        "prep -flatten -top equiv",
        "opt_clean -purge",
        # "show -prefix equiv-prep -colors 1 -stretch",
        "opt -full",
        "equiv_simple -seq 5",
        "equiv_induct -seq 5",
        "equiv_status -assert",
    ]

    script_path = os.path.join(output_dir, "%sequiv.ys" % prefix)

    with open(script_path, "w") as script_file:
        script_file.write("\n".join(script))
        script_file.close()

    # Measurements show this normally takes up to 117 seconds.
    process, duration = timed_subprocess_run(
        [
            "/usr/bin/env",
            "time",
            *make_timeout_cmd(5*60),
            "yosys",
            "-s",
            script_path,
            "-q",
            "-q",
            "-l",
            equiv_out,
        ],
        capture_output=True,
        text=True,
    )
    print(f"# run_equiv: {duration:7.3f} s; rc: {process.returncode}")
    if process.returncode:
        print("Subprocess [ %s ] returned error:" % (subprocess.list2cmdline(process.args)))
        sys.stdout.flush()
        print(process.stderr)

    return process


def get_equiv_result(surelog_out, yosys_out, output_dir, prefix=""):
    """
    Parses equivalence check log to find a final result
    """

    equiv_patterns = {
        "Same content": "PASS",  # EQUIVALENT
        "Equivalence successfully proven": "PASS",  # EQUIVALENT
        "Unproven": "DIFF",  # NOT_EQUIVALENT
        "[0-9]+ unproven": "DIFF",  # NOT_EQUIVALENT
        "ERROR: Can't find gold module surelog": "S GATE",  # INVALID_MODEL_SURELOG
        "ERROR: Can't find gate module yosys": "Y GATE",  # INVALID_MODEL_YOSYS
        "Proved 0 previously unproven \$equiv cells\.": "MODEL EM",  # EMPTY_MODEL
        "ERROR:": "MODEL_ER",  # ERROR_MODEL
    }

    log = ""
    status = "INCONCLUSIVE"

    # Check equivalence check output
    with open(os.path.join(output_dir, "%sequiv.out" % prefix), "r") as equiv_out:
        log = equiv_out.read()
        equiv_out.close()

    for pattern in equiv_patterns.keys():
        if re.search(pattern, log):
            return equiv_patterns[pattern]

    # Inconclusive, check Surelog output
    with open(os.path.join(output_dir, surelog_out), "r") as surelog_out:
        log = surelog_out.read()
        surelog_out.close()

    if re.search("Nb undefined modules: [1-9][0-9]*", log):
        status = "INCOM"
    if re.search("Dumping module ", log) == None:
        status = "S GATE"
    if re.search("^ERROR: ", log):
        status = "UH PLUG"

    # Inconclusive, check Yosys output
    with open(os.path.join(output_dir, yosys_out), "r") as yosys_out:
        log = yosys_out.read()
        yosys_out.close()

    if re.search("Dumping module ", log):
        if status == "S GATE":
            status = "NO GATE"
        elif status == "UH PLUG":
            status = "UH YGATE"
        else:
            status = "Y GATE"

    return status


def log_result(result, output_dir):
    print(result)
    with open(os.path.join(output_dir, "result.json"), "w") as result_file:
        result_file.write(json.dumps(result))
        result_file.close()


def get_test_label(name: str, test_id: int, tests_count: int, skipped: bool = False):
    prefix = ""
    if test_id > 0 and tests_count > 0:
        id_width = (
            1 if tests_count < 10 else
            2 if tests_count < 100 else
            3 if tests_count < 1000 else
            4
        )
        prefix = f"[{test_id:{id_width}}/{tests_count}] "

    if skipped:
        return f"\x1b[2m{prefix}\x1b[33m{name}\x1b[39m (skipped)\x1b[0m"
    else:
        return f"{prefix}\x1b[97;1m{name}\x1b[0m"


def group_begin(name: str, test_id: int, tests_count: int, skipped: bool = False):
    sys.stdout.flush()
    sys.stderr.flush()
    label = get_test_label(name, test_id, tests_count, skipped)
    if os.environ.get("GITHUB_ACTIONS") == "true":
        print(f"::group::{label}")
    else:
        print(label)


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

    test_id = args.test_id
    tests_count = args.tests_count
    if test_id > tests_count:
        print(f"Warning: Invalid Arguments: `test_id` ({test_id}) > `tests_count` ({tests_count}). Assuming unset.")
        test_id = tests_count = -1

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
        full_test_name = {test_name}

    # Test name suitable for use as a file name (no whitespace, `:`, `/`, control characters).
    safe_test_name = re.sub(r"[\s:/\x00-\x1f\x7f-\x9f]", "_", test_name)

    # Directory for storing result.
    output_path = args.output_dir.resolve()

    skiplist = get_skiplist(Path(__file__).parent/"formal"/"skiplist.txt")

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
    test_result = {"name": test_name}

    # Create new work directory, removing existing one if needed.
    if work_dir.is_dir():
        shutil.rmtree(work_dir)
    elif work_dir.exists():
        work_dir.unlink()
    work_dir.mkdir()

    os.chdir(work_dir)

    if full_test_name in skiplist:
        group_begin(full_test_name, test_id, tests_count, True)
        group_end()
        # Intentionally do not save test result.
        return

    group_begin(full_test_name, test_id, tests_count)
    try:
        # Run synthesis of test's source files and export Verilog
        ret_yosys = run_yosys(test_src_file, work_dir)
        processed_sv2v = False
        ys_prefix = ""
        if ret_yosys:
            ys_prefix = "sv2v_"
            test_result["yosys"] = "FAIL"
            test_result["sv2v_yosys"] = "OK"
            preprocessed_path = preprocess_sv2v(test_src_file, work_dir)
            if preprocessed_path == None:
                test_result["sv2v_yosys"] = "SV2V_FAIL"
                test_result["surelog"] = "SKIPPED"
                test_result["sv2v_surelog"] = "SKIPPED"
                return

            processed_sv2v = True
            ret_yosys = run_yosys(preprocessed_path, work_dir, ys_prefix)
            if ret_yosys:
                test_result["sv2v_yosys"] = "FAIL"
                test_result["surelog"] = "SKIPPED"
                test_result["sv2v_surelog"] = "SKIPPED"
                return
        else:
            test_result["yosys"] = "OK"
            test_result["sv2v_yosys"] = "SKIPPED"

        ret_equiv = None
        ret_surelog = run_surelog(test_src_file, work_dir)
        if not ret_surelog:
            top_module_name = get_test_top_module(work_dir)
            ret_equiv = run_equiv(top_module_name, work_dir, yosys_gate=(ys_prefix + "yosys_gate.v"))
            test_result["surelog"] = get_equiv_result("surelog.out", ys_prefix + "yosys.out", work_dir)
        else:
            test_result["surelog"] = "FAIL"

        if processed_sv2v:
            ret_surelog = run_surelog(preprocessed_path, work_dir, "sv2v_")
            if not ret_surelog:
                top_module_name = get_test_top_module(work_dir, "sv2v_")
                ret_equiv = run_equiv(top_module_name, work_dir, surelog_gate="sv2v_surelog_gate.v", yosys_gate=(ys_prefix + "yosys_gate.v"))
                test_result["sv2v_surelog"] = get_equiv_result("sv2v_surelog.out", ys_prefix + "yosys.out", work_dir, "sv2v_")
            else:
                test_result["sv2v_surelog"] = "FAIL"
        else:
            test_result["sv2v_surelog"] = "SKIPPED"

        if ret_equiv is not None:
            test_result.update(get_time_result(ret_equiv.stderr))

    finally:
        log_result(test_result, work_dir)
        group_end()


if __name__ == "__main__":
    main()
