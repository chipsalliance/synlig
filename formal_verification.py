#!/usr/bin/env python3

import re
import os
import sys
import shutil
import datetime
import subprocess


def get_test_files(test_path):
    """
    Gets a list of all source files in a given test directory
    """

    slv_file = ""
    command = []
    files = []

    for file in os.listdir(test_path):
        if file.endswith(".slv"):
            slv_file = os.path.join(test_path, file)
            break

    with open(slv_file, "r") as f:
        command = f.readline().split()
        f.close()

    for token in command:
        source_file = os.path.join(test_path, token)
        if os.path.exists(source_file):
            files.append(source_file)

    return files


def get_test_top_module(test_path):
    """
    Extracts top module name from Surelog output
    """

    log = []
    with open(os.path.join(test_path, "surelog.out"), "r") as surelog_out:
        log = surelog_out.readlines()
        surelog_out.close()

    for line in log:
        if line.startswith("Top module:"):
            return line.split("\\")[-1]


def count_messages(test_path):
    pass


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


def preprocess_sv2v(test_path, output_dir):
    """
    Converts all source files from test to Verilog with sv2v
    """

    sv2v_out = os.path.join(output_dir, "sv2v.v")
    subprocess.run(["sv2v", test_path, "-w=%s" % sv2v_out])
    return sv2v_out


def find_xilinx_cells():
    """
    Returns a path of Xilinx techlibs for default Yosys installation
    """

    yosys_bin_path = shutil.which("yosys")
    head_tail = os.path.split(yosys_bin_path)
    cells_path = os.path.join(head_tail[0], "..", "share", "yosys", "xilinx")
    return cells_path


def run_surelog(test_path, output_dir):
    """
    Writes and executes Surelog synthesis script
    """

    script = [
        "plugin -i systemverilog",
        "read_systemverilog -mutestdout %s" % test_path,
        "synth_xilinx",
        "write_verilog %s/surelog_gate.v" % output_dir,
    ]

    script_path = os.path.join(output_dir, "surelog.ys")

    with open(script_path, "w") as script_file:
        script_file.write("\n".join(script))
        script_file.close()

    process = subprocess.run(
        ["yosys", "-s", script_path, "-q", "-q", "-l", "%s/surelog.out" % output_dir],
        capture_output=True,
        text=True,
    )

    if process.stdout == "":
        return True
    return False


def run_yosys(test_path, output_dir):
    """
    Writes and executes Yosys synthesis script
    """

    script = [
        "read_verilog %s" % test_path,
        "synth_xilinx",
        "write_verilog %s/yosys_gate.v" % output_dir,
    ]

    script_path = os.path.join(output_dir, "yosys.ys")

    with open(script_path, "w") as script_file:
        script_file.write("\n".join(script))
        script_file.close()

    process = subprocess.run(
        ["yosys", "-s", script_path, "-q", "-q", "-l", "%s/yosys.out" % output_dir],
        capture_output=True,
        text=True,
    )

    if process.stdout == "":
        return True
    return False


def run_equiv(top_module, output_dir):
    """
    Writes and executes Yosys equivalence check script
    """

    cells_path = find_xilinx_cells()
    cells = [
        os.path.join(cells_path, "cells_sim.v"),
        os.path.join(cells_path, "cells_xtra.v"),
    ]

    script = [
        "read_verilog %s/surelog_gate.v %s %s" % (output_dir, cells[0], cells[1]),
        "prep -flatten -top %s" % top_module,
        "splitnets -ports;;",
        "design -stash surelog",
        "read_verilog %s/yosys_gate.v %s %s" % (output_dir, cells[0], cells[1]),
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

    script_path = os.path.join(output_dir, "equiv.ys")

    with open(script_path, "w") as script_file:
        script_file.write("\n".join(script))
        script_file.close()

    process = subprocess.run(
        [
            "/usr/bin/env",
            "time",
            "yosys",
            "-s",
            script_path,
            "-q",
            "-q",
            "-l",
            "%s/equiv.out" % output_dir,
        ],
        capture_output=True,
        text=True,
    )

    return process


def get_equiv_result(output_dir):
    """
    Parses equivalence check log to find a final result
    """

    equiv_patterns = {
        "Equivalence successfully proven": "PASS",  # EQUIVALENT
        "Unproven": "DIFF",  # NOT_EQUIVALENT
        "[0-9]+ unproven": "DIFF",  # NOT_EQUIVALENT
        "ERROR: Can't find gold module surelog": "S GATE",  # INVALID_MODEL_SURELOG
        "ERROR: Can't find gate module yosys": "Y GATE",  # INVALID_MODEL_YOSYS
        "Proved 0 previously unproven \$equiv cells\.": "MODEL EM",  # EMPTY_MODEL
        "ERROR:": "MODEL_ER",  # ERROR_MODEL
    }
    surelog_patterns = {
        "Nb undefined modules: [1-9][0-9]*": "INCOM",
        "Dumping module ": "S GATE",
    }

    log = ""
    status = "INCONCLUSIVE"

    # Check equivalence check output
    with open(os.path.join(output_dir, "equiv.out"), "r") as equiv_out:
        log = equiv_out.read()
        equiv_out.close()

    for pattern in equiv_patterns.keys():
        if re.search(pattern, log):
            status = equiv_patterns[pattern]

    # Inconclusive, check Surelog output
    with open(os.path.join(output_dir, "surelog.out"), "r") as surelog_out:
        log = surelog_out.read()
        surelog_out.close()

    for pattern in surelog_patterns.keys():
        if re.search(pattern, log):
            status = surelog_patterns[pattern]

    for line in log.splitlines():
        if re.search("^ERROR: ", line):
            status = "UH PLUG"

    # Inconclusive, check Yosys output
    with open(os.path.join(output_dir, "yosys.out"), "r") as yosys_out:
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


def main():
    test_path = os.path.abspath(os.path.normpath(sys.argv[1]))
    sv2v_pass = True

    # Prepare names and paths of test files and working directory
    test_name = os.path.basename(test_path)
    test_files = get_test_files(test_path)
    test_files_str = " ".join(test_files)
    test_target = "%s_%s" % (test_name, os.path.basename(test_files[0]))
    work_dir = os.path.join(os.getcwd(), "build", "tests", test_target)

    # Create new work directory
    if os.path.isdir(work_dir):
        shutil.rmtree(work_dir)
    os.mkdir(work_dir)
    os.chdir(work_dir)

    preprocessed_path = preprocess_sv2v(test_files_str, work_dir)

    # Run synthesis of test's source files and export Verilog
    ret_yosys_sv2v = run_yosys(preprocessed_path, work_dir)
    if sv2v_pass == False:
        ret_surelog = run_surelog(preprocessed_path, work_dir)
    else:
        ret_surelog = run_surelog(test_files_str, work_dir)

    # Equivalance check
    if ret_yosys_sv2v == True and ret_surelog == True:
        top_module_name = get_test_top_module(work_dir)
        ret_equiv = run_equiv(top_module_name, work_dir)
        print(get_time_result(ret_equiv.stderr))
        result = get_equiv_result(work_dir)

    print("%s: %s" % (test_target, result))


if __name__ == "__main__":
    main()
