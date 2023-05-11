#!/usr/bin/env python3

import subprocess
import argparse
import sys
import os

from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent / "lib" / "python3"))

from yosys_systemverilog.run_command import run_command


def gen_tests(test_suite_dir, output_dir):

    for sub_suite_dir in Path(test_suite_dir).glob("bsg_*"):
        for input_v_file in Path(sub_suite_dir).rglob("top.v"):
            test_name = os.path.basename(os.path.dirname(input_v_file))
            design_name = os.path.basename(Path(input_v_file).parent.parent)
            output_dest = os.path.join(output_dir, design_name, test_name)

            script = [
                "plugin -i systemverilog",
                "read_systemverilog %s" % (input_v_file),
                "synth -top %s -flatten" % (design_name),
                "write_verilog -noattr %s/dut.v" % (output_dest),
            ]

            script_path = os.path.join(output_dest, "surelog.ys")

            if not Path(output_dest).exists():
                Path(output_dest).mkdir(parents=True)

            with open(script_path, "w") as script_file:
                script_file.write("\n".join(script))
                script_file.close()

            run_command(
                    ["yosys", "-s", script_path, "-q", "-q", "-l", f"{output_dest}/surelog.out"],
                    timeout=10*60,
                    vmem_limit_kb=2*1024*1024,
                    capture_stderr=True,
                    oom_score_adj=500
                )


def diff_tests(test_dir, ref_dir, gen_v_dir):

    difflist = list()
    passlist = list()

    for ref_test in Path(ref_dir).rglob("gold.v"):
        test_name = os.path.basename(os.path.dirname(ref_test))
        preprocess_test(ref_test)

        # Find the catalogue in the test directory basing on the directory of the referencial gold.v
        for p in Path(test_dir).rglob(test_name):
            for gen_test in Path(os.path.dirname(p)).rglob("top.v"):
                preprocess_test(gen_test)
                sp = subprocess.run(["diff %s %s > %s.diff" % (ref_test, gen_test, gen_test)], shell=True)

                # Diff dut.v files only for the tests with matching top.v and gold.v (from the reference test set)
                if check_ref_test("%s.diff" % gen_test):
                    ref_v_path = os.path.join(os.path.dirname(ref_test), "dut.v")
                    gen_v_name = os.path.join(test_name.removesuffix(".json"), os.path.basename(os.path.dirname(gen_test)), "dut.v")
                    gen_v_path = os.path.join(gen_v_dir, gen_v_name)

                    if os.path.isfile(ref_v_path) and os.path.isfile(gen_v_path):
                        preprocess_test(ref_v_path)
                        preprocess_test(gen_v_path)
                        diffpath = "%s.diff" % gen_v_path
                        sp = subprocess.run(["diff %s %s > %s" % (ref_v_path, gen_v_path, diffpath)], shell=True)

                        if not os.stat(diffpath).st_size == 0:
                            difflist.append("%s.diff" % gen_v_name)
                        else:
                            passlist.append("%s.diff" % gen_v_name)

    list_diffs_and_passes(difflist, passlist, test_dir, gen_v_dir)


def preprocess_test(filename):

    # Remove comments /* */, (* *) and empty lines
    sp = subprocess.run(["sed -i -e '/\(\* .* \*\)/d' -e '/^\s*$/d' %s" % filename], shell=True)


def check_ref_test(name):

    return True if not os.stat(name).st_size else False


def list_diffs_and_passes(difflist, passlist, test_suite, output_dir):

    difflist_name = "%s/%s_difflist.txt" % (output_dir, os.path.basename(test_suite))
    passlist_name = "%s/%s_passlist.txt" % (output_dir, os.path.basename(test_suite))

    difflist.sort()
    passlist.sort()

    with open(difflist_name, "w") as diff_file:
        diff_file.writelines(line + "\n" for line in difflist)
        diff_file.close()

    with open(passlist_name, "w") as pass_file:
        pass_file.writelines(line + "\n" for line in passlist)
        pass_file.close()

    if not os.stat(difflist_name).st_size == 0:
        # Print warning in style of GH actions annotation
        print("::warning::Some generated tests differ from the reference. Check the list of diffs in `%s` in the `bsg-tests-diffs` artifacts."
              % os.path.basename(difflist_name))


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

    gen_tests(test_suite_dir, output_dir)
    diff_tests(test_suite_dir, ref_test_dir, output_dir)


if __name__ == "__main__":
    main()
