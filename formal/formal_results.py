#!/usr/bin/env python3

import json
import os
import sys


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


def main():
    results_path = os.path.abspath(os.path.normpath(sys.argv[1]))
    result_files = []
    result_count = {}
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
                result_count["RES_ERR"] += 1
                continue
            result_count[result_data["result"]] += 1

    formatted_results = []
    for r in result_count:
        formatted_results.append([r, result_count[r], result_descriptions[r]])

    for row in formatted_results:
        print("{: >12} : {: >4} | {}".format(*row))


if __name__ == "__main__":
    main()
