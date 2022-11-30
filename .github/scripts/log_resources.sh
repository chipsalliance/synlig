#!/bin/bash
set -e -u -o pipefail
shopt -s nullglob
shopt -s extglob
LOG_OUT="$1"
CTL_FILE="$2"
touch "$LOG_OUT"
# Run the loop as long as $CTL_FILE exists
while [[ -e "$CTL_FILE" ]]; do
  printf '========== %s ==========\n' "$(date)" >> "$LOG_OUT"
  top -o %MEM -b | head -n30 >> "$LOG_OUT"
  echo >> "$LOG_OUT"
  sleep 5
done
