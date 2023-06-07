#!/usr/bin/env python3

import subprocess
import argparse
import json
import sys
import os
import re

from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent / "lib" / "python3"))

from yosys_systemverilog.run_command import run_command


def gen_tests(test_name, test_suite_dir, test_ref_dir, output_dir):

    json_cfg_file = os.path.join(test_suite_dir, test_name , test_name + ".json")
    with open(json_cfg_file, "r") as file:
        cfg_data = json.load(file)

    fileset = cfg_data["filelist"]
    parameters = cfg_data["run_config"][0]["parameters"]

    for filename in fileset:
        if filename == "src/bsg_defines.v":
            continue
        test_file = os.path.join(test_suite_dir, test_name + "/" + filename)
        if os.path.isfile(test_file):
            with open(test_file) as v_file:
                test_module = v_file.readlines()
                v_file.close()
        else:
            print("Warning: '%s' is not present in the source directory of `%s` test." % (filename, test_name))
            return

        module_init = True
        for test_line in test_module:

            if re.search("BSG_ABSTRACT_MODULE", test_line):
                test_module.remove(test_line)
            if re.search(r"^module.*", test_line):
                module_init = True
            while re.search("`BSG_INV_PARAM", test_line):
                idx = test_module.index(test_line)
                i_start = test_line.find("#(")
                if i_start >= 0:
                    i_start = i_start + 2
                else:
                    i_start = test_line.find(",") + 1
                m_start = test_line.find("`BSG_INV_PARAM")
                p_start = m_start + 1 + test_line[m_start:].find("(")
                p_stop = test_line[p_start:].find(")")
                param = test_line[p_start:p_start+p_stop]
                for p in parameters:
                    s = p.split("=")
                    test_param = test_line[p_start:].find(s[0])
                    if test_param >= 0:
                        param = test_line[p_start:][:p_stop] + "=%s" % s[1]
                        break
                if test_line[p_start:][p_stop+1:].find(")") >= 0:
                    module_init = False
                test_line = test_line[:i_start] + param + test_line[p_start:][p_stop+1:]
                test_module[idx] = test_line
            if re.search("parameter", test_line) and module_init:
                idx = test_module.index(test_line)
                parameters_names = list()
                parameters_values = list()
                for p in parameters:
                    parameters_names.append(p.split("=")[0])
                    parameters_values.append(p.split("=")[1])
                found_params = re.findall(r"(\w+)=(\d+)", test_line)
                for fp in found_params:
                    if fp[0] in parameters_names:
                        i = parameters_names.index(fp[0])
                        v_start = test_line.find(fp[1])
                        v_stop = v_start + len(fp[1])
                        test_line = test_line[:v_start] + parameters_values[i] + test_line[v_stop:]
                        test_module[idx] = test_line
            if re.search("\)\n", test_line) and module_init:
                module_init = False

        preprocessed_file = test_file
        with open(preprocessed_file, "w") as v_file_top:
            for line in test_module:
                v_file_top.writelines(line)

    run_sv_plugin(test_name, fileset, test_suite_dir, output_dir)


def run_sv_plugin(test_name, fileset, test_suite_dir, output_dir):

    output_dest = os.path.join(output_dir, test_name)
    input_v_files = ""
    for f in fileset:
        input_v_files = input_v_files + test_suite_dir + "/" + test_name + "/" + f + " " 

    script = [
        "plugin -i systemverilog",
        "read_systemverilog -debug %s" % (input_v_files),
        "synth -top %s -flatten" % (test_name),
        "write_verilog -noattr %s/dut.v" % (output_dest),
    ]

    script_path = os.path.join(output_dest, "surelog.ys")

    if not Path(output_dest).exists():
        Path(output_dest).mkdir(parents=True)

    with open(script_path, "w") as script_file:
        script_file.write("\n".join(script))
        script_file.close()

    run_command(
            ["yosys", "-s", script_path, "-l", f"{output_dest}/surelog.out"],
            timeout=10*60,
            vmem_limit_kb=2*1024*1024,
            capture_stderr=True,
            oom_score_adj=500
        )


def diff_tests(test_dir, ref_dir, gen_v_dir):

    difflist = list()
    passlist = list()
    faultlist = list()

    for test_name in os.listdir(ref_dir):

        ref_v_path = os.path.join(ref_dir, test_name, "dut.v")
        gen_v_name = os.path.join(test_name.removesuffix(".json"), "dut.v")
        gen_v_path = os.path.join(gen_v_dir, gen_v_name)

        if os.path.isfile(ref_v_path) and os.path.isfile(gen_v_path):
            preprocess_test(ref_v_path)
            preprocess_test(gen_v_path)
            diffpath = "%s.diff" % gen_v_path
            sp = subprocess.run(["diff %s %s > %s" % (ref_v_path, gen_v_path, diffpath)], shell=True)

            if not os.stat(diffpath).st_size == 0:
                difflist.append(os.path.dirname(gen_v_name))
            else:
                passlist.append(os.path.dirname(gen_v_name))

        elif os.path.isfile(ref_v_path):
            faultlist.append(test_name.removesuffix(".json"))

    list_diffs_and_passes(difflist, passlist, faultlist, test_dir, gen_v_dir)


def preprocess_test(filename):

    # Remove comments /* */, (* *) and empty lines
    sp = subprocess.run(["sed -i -e '/\(\* .* \*\)/d' -e '/^\s*$/d' %s" % filename], shell=True)


def check_ref_test(name):

    return True if not os.stat(name).st_size else False


def list_diffs_and_passes(difflist, passlist, faultlist, test_suite, output_dir):

    summary_name = "%s/%s_summary.md" % (output_dir, os.path.basename(test_suite))

    difflist.sort()
    passlist.sort()
    faultlist.sort()

    with open(summary_name, "w") as sum_file:
        if passlist:
            sum_file.writelines("### Generated tests that are the same as the reference\n")
            sum_file.writelines(":heavy_check_mark: " + line + "\n" for line in passlist)
        if difflist:
            sum_file.writelines("### Generated tests that differ from the reference\n")
            sum_file.writelines(":heavy_exclamation_mark: " + line + "\n" for line in difflist)
        if faultlist:
            sum_file.writelines("### Tests that failed to be generated\n")
            sum_file.writelines(":x: " + line + "\n" for line in faultlist)
        sum_file.close()

    if difflist or faultlist:
        # Print warning in style of GH actions annotation
        print("::warning::Some generated tests differ from the reference or were not generated at all. Check the test statuses in the workflow summary or `%s` in the `bsg-tests-diffs` artifacts."
              % os.path.basename(summary_name))

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("--test-suite-dir", type=Path, default=Path.cwd()/"bsg_micro_designs",
            help="Test suite directory to generate verilog netlists from.")
    parser.add_argument("--ref-test-dir", type=Path, default=Path.cwd()/"UHDM-integration-tests"/"tests"/"bsg"/"bsg_micro_designs_results",
            help="Referential test directory to compare generated verilog netlists with.")
    parser.add_argument("--output-dir", type=Path, default=Path.cwd()/"build"/"tests"/"bsg_micro_designs",
            help="Output directory for the generated verilog files.")
    args = parser.parse_args()

    output_dir = args.output_dir
    test_suite_dir = args.test_suite_dir
    ref_test_dir = args.ref_test_dir

    for sub_suite_dir in Path(test_suite_dir).glob("bsg_*"):
        for json_file in Path(sub_suite_dir).rglob("*.json"):
            test_name = os.path.basename(os.path.dirname(json_file))
            gen_tests(test_name, os.path.relpath(sub_suite_dir), ref_test_dir, output_dir)

    diff_tests(test_suite_dir, ref_test_dir, output_dir)


if __name__ == "__main__":
    main()
