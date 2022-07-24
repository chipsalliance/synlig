#!/bin/sh

set -e

# Copyright 2022 Alain Dargelas
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Usage:
# ./build_binaries.sh --build-sv2v
# ./run_formal_verif.sh



SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")
mkdir -p build
mkdir -p build/tests

cd sv2v/test
../../Surelog/tests/create_batch_script.tcl  ext=.v,.sv batch=batch.txt options="+incdir+. -parse -nocache -nobuiltin -nonote -noinfo -timescale=1ns/1ns" verification
cd ../../

cd yosys/tests/
../../Surelog/tests/create_batch_script.tcl  ext=.v,.sv batch=batch.txt options="+incdir+. -parse -nocache -nobuiltin -nonote -noinfo -timescale=1ns/1ns" verification
cd ../../


cd UHDM-integration-tests/tests
../../Surelog/tests/create_batch_script.tcl  ext=.v,.sv batch=batch.txt options="+incdir+. -parse -nocache -nobuiltin -nonote -noinfo -timescale=1ns/1ns" verification
cd ../../

cd build

echo "Yosys Regression"
../Surelog/tests/regression.tcl search_dir=../yosys/tests path=$SCRIPTPATH/image/bin/ yosys_exe=$SCRIPTPATH/image/bin/yosys sv2v_exe=$SCRIPTPATH/image/bin/sv2v verification
echo "UHDM-integration Regression"
../Surelog/tests/regression.tcl search_dir=../UHDM-integration-tests/tests path=$SCRIPTPATH/image/bin/ yosys_exe=$SCRIPTPATH/image/bin/yosys sv2v_exe=$SCRIPTPATH/image/bin/sv2v verification
echo "SV2V Regression"
../Surelog/tests/regression.tcl search_dir=../sv2v/test path=$SCRIPTPATH/image/bin/ yosys_exe=$SCRIPTPATH/image/bin/yosys sv2v_exe=$SCRIPTPATH/image/bin/sv2v verification
