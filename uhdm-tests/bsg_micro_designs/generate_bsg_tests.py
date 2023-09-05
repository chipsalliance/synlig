#!/usr/bin/env python3

import subprocess
import argparse
import json
import sys
import re

from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent.parent / "lib" / "python3"))

from yosys_systemverilog.run_command import run_command


def gen_tests(test_name, test_suite_dir, test_ref_dir, output_dir):

    json_cfg_file = test_suite_dir / test_name / f"{test_name}.json"
    with open(json_cfg_file, "r") as file:
        cfg_data = json.load(file)

    fileset = cfg_data["filelist"]
    parameters = cfg_data["run_config"][0]["parameters"]

    output_dest = output_dir / test_name
    if not output_dest.exists():
        output_dest.mkdir(parents=True)

    for filename in fileset:
        if filename == "src/bsg_defines.v":
            continue
        test_file = test_suite_dir / test_name / filename
        if test_file.is_file():
            with open(test_file) as v_file:
                test_module = v_file.readlines()
        else:
            print(f"Warning: '{filename}' is not present in the source directory of `{test_name}` test.")
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
                        param = test_line[p_start:][:p_stop] + f"={s[1]}"
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

    dut_v_file = run_sv_plugin(test_name, fileset, test_suite_dir, output_dir)

    # Generate parameters file only when dut.v has been generated
    if dut_v_file.exists():
        with open(output_dest / "parameters.txt", "w") as p_file:
            p_file.writelines(param + "\n" for param in parameters)


def run_sv_plugin(test_name, fileset, test_suite_dir, output_dir):

    output_dest = output_dir / test_name
    input_v_files = ""
    for f in fileset:
        input_v_files = input_v_files + str(test_suite_dir / test_name / f) + " "

    dut_v_file = output_dest / "dut.v"

    script = [
        "plugin -i systemverilog",
        f"read_systemverilog -debug {input_v_files}",
        f"synth -top {test_name} -flatten",
        f"write_verilog -noattr {dut_v_file}",
    ]

    script_path = output_dest / "surelog.ys"

    if not Path(output_dest).exists():
        Path(output_dest).mkdir(parents=True)

    with open(script_path, "w") as script_file:
        script_file.write("\n".join(script))

    run_command(
            ["yosys", "-s", script_path, "-l", f"{output_dest}/surelog.out"],
            timeout=10*60,
            vmem_limit_kb=2*1024*1024,
            capture_stderr=True,
            oom_score_adj=500
        )

    return dut_v_file


def diff_tests(test_dir, ref_dir, gen_v_dir):

    difflist = list()
    passlist = list()
    faultlist = list()

    for test_name in ref_dir.iterdir():

        ref_v_path = ref_dir / test_name / "dut.v"
        gen_v_name = Path(test_name.stem + "/dut.v")
        gen_v_path = gen_v_dir / gen_v_name

        if ref_v_path.is_file() and gen_v_path.is_file():
            preprocess_test(ref_v_path)
            preprocess_test(gen_v_path)
            diffpath = Path(f"{gen_v_path}.diff")
            sp = subprocess.run([f"diff {ref_v_path} {gen_v_path} > {diffpath}"], shell=True)

            if not diffpath.stat().st_size == 0:
                difflist.append(str(gen_v_name.parent))
            else:
                passlist.append(str(gen_v_name.parent))

        elif ref_v_path.is_file():
            faultlist.append(test_name.stem)

    list_diffs_and_passes(difflist, passlist, faultlist, test_dir, gen_v_dir)


def preprocess_test(filename):

    # Remove comments /* */, (* *) and empty lines
    with open(filename, "r+") as f:
        lines = f.readlines()
        for s in lines:
            idx = lines.index(s)
            s = re.sub(r"\(\*.+?\*\)|/\*.*?\*/", "", s)
            s = re.sub(r"^\s*$", "", s)
            lines[idx] = s
        f.seek(0)
        f.writelines(lines)
        f.truncate()


def list_diffs_and_passes(difflist, passlist, faultlist, test_suite, output_dir):

    summary_name = Path(f"{output_dir}/{test_suite.name}_summary.md")

    difflist.sort()
    passlist.sort()
    faultlist.sort()

    with open(summary_name, "w") as sum_file:
        if difflist:
            sum_file.writelines("<details open><summary><strong>")
            sum_file.writelines(":heavy_exclamation_mark: Generated tests that differ from the reference\n")
            sum_file.writelines("</strong></summary><p><ul>\n")
            sum_file.writelines(f"<li>{line}</li>\n" for line in difflist)
            sum_file.writelines("</ul></p></details>\n")
        if faultlist:
            sum_file.writelines("<details open><summary><strong>")
            sum_file.writelines(":x: Tests that failed to be generated\n")
            sum_file.writelines("</strong></summary><p><ul>\n")
            sum_file.writelines(f"<li>{line}</li>\n" for line in faultlist)
            sum_file.writelines("</ul></p></details>\n")
        if passlist:
            sum_file.writelines("<details><summary><strong>")
            sum_file.writelines(":heavy_check_mark: Generated tests that are the same as the reference\n")
            sum_file.writelines("</strong></summary><p><ul>\n")
            sum_file.writelines(f"<li>{line}</li>\n" for line in passlist)
            sum_file.writelines("</ul></p></details>\n")

    if difflist or faultlist:
        # Print warning in style of GH actions annotation
        print(f"::warning::Some generated tests differ from the reference or were not generated at all. Check the test statuses in the workflow summary or `{summary_name.name}` in the artifacts.")

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("--test-suite-dir", type=Path, default=Path.cwd()/"third_party"/"bsg_micro_designs",
            help="Test suite directory to generate verilog netlists from.")
    parser.add_argument("--ref-test-dir", type=Path, default=Path.cwd()/"uhdm-tests"/"bsg_micro_designs"/"results",
            help="Referential test directory to compare generated verilog netlists with.")
    parser.add_argument("--output-dir", type=Path, default=Path.cwd()/"uhdm-tests"/"bsg_micro_designs"/"build",
            help="Output directory for the generated verilog files.")
    args = parser.parse_args()

    output_dir = args.output_dir
    test_suite_dir = args.test_suite_dir
    ref_test_dir = args.ref_test_dir

    for sub_suite_dir in Path(test_suite_dir).glob("bsg_*"):
        for json_file in Path(sub_suite_dir).rglob("*.json"):
            test_name = json_file.parent.name
            gen_tests(test_name, sub_suite_dir, ref_test_dir, output_dir)

    diff_tests(test_suite_dir, ref_test_dir, output_dir)


if __name__ == "__main__":
    main()
