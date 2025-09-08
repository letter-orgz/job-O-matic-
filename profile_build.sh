#!/usr/bin/env bash
set -euo pipefail
LOGFILE="build_timings.log"

# Empty log file
: > "$LOGFILE"

# Function to time a step
step() {
  local name="$1"
  shift
  echo "=== $name ==="
  local start=$(date +%s)
  "$@"
  local exit_code=$?
  local end=$(date +%s)
  local duration=$(( end - start ))
  printf '%s,%d\n' "$name" "$duration" >> "$LOGFILE"
  return $exit_code
}

# Example build steps
step "Install dependencies" pip install -r requirements.txt
step "Run tests" pytest
step "Package app" tar -czf app.tar.gz app.py src/

echo "Timing results written to $LOGFILE"
