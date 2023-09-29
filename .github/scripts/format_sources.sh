#!/usr/bin/env bash

find frontends third_party/yosys_mod \
    -name "*.h" -o -name "*.cc" \
    | xargs clang-format -i
