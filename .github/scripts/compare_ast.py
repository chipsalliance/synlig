#!/usr/bin/env python3
import re
import os
import sys
import subprocess

def parse_file(file_path):
    module_dict = {}
    current_module_name = ""
    with open(file_path, 'r') as f:
        lines = f.readlines()
        for line in lines:
            if "Generating" in line or "Dumping" in line or "END OF AST DUMP" in line:
                continue
            stripped_line = line.strip()
            if stripped_line.startswith("AST_MODULE"):
                line = line.replace("basic_prep", "")
                start = line.find("str='")
                line = line.rstrip()
                module_name = line[start+5:]
                #if module_name.endswith('\''):
                #    module_name = module_name[:-1]
                if "\\$paramod" in module_name:
                    current_module_name = module_name.replace("\\$paramod", "")
                else:
                    current_module_name = module_name
                begin = current_module_name.find("\\")
                if begin != -1:
                    end = current_module_name.find("\\", begin + 1, len(current_module_name))
                    current_module_name = current_module_name[begin:end]
                if current_module_name == "":
                    current_module_name = module_name
                current_module_name = current_module_name.replace(' ', '')
                current_module_name = current_module_name.replace('\\', '')


            if current_module_name != "":
                if "\n" not in line:
                    line = line + "\n"
                if current_module_name in module_dict:
                    module_dict[current_module_name].append(line)
                else:
                    module_dict[current_module_name] = [line]

            line = f.readline()

    return module_dict

first = parse_file(sys.argv[1])
second = parse_file(sys.argv[2])

os.makedirs("compare", exist_ok=True)

first_sorted = {}
second_sorted = {}

for key in sorted(first.keys()):
    start_skip = False
    skip_line = 0
    current_line = 1
    for line in first[key]:
        if key in first_sorted:
            first_sorted[key].append(line)
        else:
            first_sorted[key] = [line]
        current_line += 1

    with open(f'compare/first_{key}.ast', 'w') as f:
        f.writelines(first[key])

for key in sorted(second.keys()):
    start_skip = False
    skip_line = 0
    current_line = 1
    for line in second[key]:
        if key in second_sorted:
            second_sorted[key].append(line)
        else:
            second_sorted[key] = [line]
        current_line += 1

    with open(f'compare/second_{key}.ast', 'w') as f:
        f.writelines(second[key])

for key in first.keys():
    if key in second.keys():
        subprocess.run(["diff", f"compare/first_{key}.ast", f"compare/second_{key}.ast"])
        second.pop(key)
    else:
        print(f"Additional module in first file: {key}")

for key in second.keys():
    print(f"Additional module in second file: {key}")

