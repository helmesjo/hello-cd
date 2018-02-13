#!/bin/bash
set -euo pipefail

function on_error {
    (>&2 echo "Could not find a c++ compiler")
    sleep 3
    exit 1
}
trap on_error ERR

REPO_ROOT=$(git rev-parse --show-toplevel)
OS="$($REPO_ROOT/scripts/get-os.sh 2>&1 >/dev/null)"

# Determine OS & compiler
COMPILER="compiler_not_found"

if command -v gcc >/dev/null; then
    COMPILER="gcc"
elif command -v clang >/dev/null; then
    COMPILER="clang"
elif [ $OS = "windows" ]; then
    COMPILER="msvc"
fi

(>&2 echo "$COMPILER")