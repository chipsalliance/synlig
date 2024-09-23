#!/bin/python3

from pathlib import Path
import argparse
import sys

parser = argparse.ArgumentParser()
parser.add_argument("--mod_dir", type=Path, default=".", help="Directory containing PySynlig module.")
parser.add_argument("--uhdm_file", type=Path, required=True, help="Uhdm file with design to synthesis.")
parser.add_argument("--edif_file", type=Path, default="design.edif", help="Edif output file.")
args = parser.parse_args();

sys.path.append(str(args.mod_dir))
from PySynlig import libsynlig

libsynlig.run_pass("read_uhdm " + str(args.uhdm_file))
libsynlig.run_pass("synth_xilinx -iopad -family xc7")
libsynlig.run_pass("write_edif " + str(args.edif_file))
