#!/usr/bin/env bash

find third_party/yosys_mod src/ \
    -name "*.h" -o -name "*.cc" \
    | xargs clang-format -i
