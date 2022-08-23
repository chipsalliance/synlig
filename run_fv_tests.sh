#!/bin/bash
export PATH=`pwd`/image/bin:$PATH
testsuite=$(realpath $1)
pushd $testsuite
../../Surelog/tests/create_batch_script.tcl  ext=.v,.sv batch=batch.txt options="+incdir+. -parse -nocache -nobuiltin -nonote -noinfo -timescale=1ns/1ns" verification
popd
find $testsuite -maxdepth 1 -mindepth 1 -type d -exec python3 ./formal_verification.py {} \;
