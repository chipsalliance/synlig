#!/usr/bin/env python3


import re
import os
import sys
import json
import shutil
import subprocess


def get_tests(test_path):
    """
    Gets all tests available in a given path
    """

    slv_files = []

    if os.path.isfile(test_path) and test_path.endswith(".slv"):
        slv_files.append(test_path)
        return slv_files

    for file in os.listdir(test_path):
        if file.endswith(".slv"):
            slv_files.append(os.path.join(test_path, file))

    return slv_files


def get_skiplist(listfile):
    """
    Gets a list of tests to be skipped
    """
    list = []
    with open(listfile, "r") as f:
        list = f.read().splitlines()
        f.close()

    for el in list:
        if el.startswith("#"):
            list.remove(el)

    return list


def get_test_files(slv_file):
    """
    Gets all source files used by given test
    """

    command = []
    files = []

    with open(slv_file, "r") as f:
        command = f.readline().split()
        f.close()

    test_base = os.path.dirname(slv_file)

    for token in command:
        source_file = os.path.join(test_base, token)
        if os.path.exists(source_file):
            files.append(source_file)

    return files


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


def preprocess_sv2v(test_sources, work_path):
    """
    Converts all source files from test to Verilog with sv2v
    """

    sv2v_out = os.path.join(work_path, "sv2v.v")
    process = subprocess.run(["sv2v", test_sources, "-w=%s" % sv2v_out])
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


def run_surelog(test_path, output_dir, prefix=""):
    """
    Writes and executes Surelog synthesis script
    """

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

    process = subprocess.run(
        ["yosys", "-s", script_path, "-q", "-q", "-l", "%s/%ssurelog.out" % (output_dir, prefix)],
        capture_output=True,
        text=True,
    )

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

    process = subprocess.run(
        ["yosys", "-s", script_path, "-q", "-q", "-l", "%s/%syosys.out" % (output_dir, prefix)],
        capture_output=True,
        text=True,
    )

    return process.returncode


def run_equiv(top_module, output_dir, surelog_gate="surelog_gate.v", yosys_gate="yosys_gate.v"):
    """
    Writes and executes Yosys equivalence check script
    """

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

    if surelog_gate.startswith("sv2v_"):
        prefix = "sv2v_"
    else:
        prefix = ""

    script_path = os.path.join(output_dir, "%sequiv.ys" % prefix)

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
            "%s/%sequiv.out" % (output_dir, prefix),
        ],
        capture_output=True,
        text=True,
    )
    if process.returncode:
        print("Subprocess [ %s ] returned error:" % (subprocess.list2cmdline(process.args)))
        print(process.stderr)

    return process


def get_equiv_result(surelog_out, yosys_out, output_dir, prefix=""):
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


def main():
    test_path = os.path.abspath(os.path.normpath(sys.argv[1]))
    output_path = os.path.join(os.getcwd(), "build", "tests")

    if len(sys.argv) < 2:
        print("No test path passed")
        for res in result_descriptions:
            print("%s: %s" % (res, result_descriptions[res]))
        exit(1)

    # Prepare names and paths of test files and working directory
    tests = get_tests(test_path)
    if not os.path.isdir(output_path):
        os.makedirs(output_path)

    skiplist = get_skiplist(os.path.join(".", "formal", "skiplist.txt"))

    test_dir = os.path.split(test_path)[0]
    if (os.path.basename(test_dir) != "test") and (os.path.basename(test_dir) != "tests"):
        test_dir = test_dir.split("/tests/")
        if len(test_dir) < 2:
            test_dir = test_dir[0].split("/test/")
        test_suite = os.path.basename(test_dir[0])
        test_dir = test_dir[1].replace("/", "_")
    else:
        test_suite = os.path.basename(os.path.split(test_dir)[0])
        test_dir = ""

    for test in tests:
        test_name = os.path.basename(test).removesuffix(".slv")
        test_files = get_test_files(test)
        test_files_str = " ".join(test_files)
        if test_dir:
            test_name = "_".join([test_dir, test_name])
        work_dir = os.path.join(output_path, test_suite, test_name)
        test_result = {"name": test_name}

        # Create new work directory
        if os.path.isdir(work_dir):
            shutil.rmtree(work_dir)
        os.makedirs(work_dir)
        os.chdir(work_dir)


        if test_name in skiplist:
            test_result["result"] = "SKIPPED"
            continue
        # Run synthesis of test's source files and export Verilog
        ret_yosys = run_yosys(test_files_str, work_dir)
        processed_sv2v = False
        ys_prefix = ""
        if ret_yosys:
            ys_prefix = "sv2v_"
            test_result["yosys"] = "FAIL"
            test_result["sv2v_yosys"] = "OK"
            preprocessed_path = preprocess_sv2v(test_files_str, work_dir)
            if preprocessed_path == None:
                test_result["sv2v_yosys"] = "SV2V_FAIL"
                test_result["surelog"] = "SKIPPED"
                test_result["sv2v_surelog"] = "SKIPPED"
                log_result(test_result, work_dir)
                continue

            processed_sv2v = True
            ret_yosys = run_yosys(preprocessed_path, work_dir, ys_prefix)
            if ret_yosys:
                test_result["sv2v_yosys"] = "FAIL"
                test_result["surelog"] = "SKIPPED"
                test_result["sv2v_surelog"] = "SKIPPED"
                log_result(test_result, work_dir)
                continue
        else:
            test_result["yosys"] = "OK"
            test_result["sv2v_yosys"] = "SKIPPED"

        ret_surelog = run_surelog(test_files_str, work_dir)
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


        test_result.update(get_time_result(ret_equiv.stderr))
        log_result(test_result, work_dir)


if __name__ == "__main__":
    main()
