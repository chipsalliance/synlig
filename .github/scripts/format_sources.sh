#!/usr/bin/env bash

find src/ \
    -name "*.h" -o -name "*.cc" \
    | xargs clang-format -i
