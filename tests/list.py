#!/usr/bin/env python

import argparse
import json
import os
import os.path

parser = argparse.ArgumentParser()
parser.add_argument('--part', '-p', type=int, default=None,
                    help='take specified part of tests;' +
                    '[(p-1)*256 : p*256] in lexicographical order,' +
                    'all tests if unset')

parser.add_argument('--directory', '-d', type=str,
                    help='generate list from the specified directory')

parser.add_argument('--skip-elements', '-s',
                    nargs='*', default=[],
                    help='list of elements to skip')

args = parser.parse_args()

if args.directory[-1] == "/":
    args.directory = args.directory[:-1]

part_of_tests = sorted(os.listdir(args.directory))
if args.part is not None:
    part_of_tests = part_of_tests[(args.part - 1) * 256 : args.part * 256]

print(json.dumps([f"{args.directory}/{node}" for node in part_of_tests
    if node not in args.skip_elements and os.path.isdir(args.directory + "/" + node)]))
