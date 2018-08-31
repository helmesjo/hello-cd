#!/bin/bash
set -euo pipefail

function on_error {
    (>&2 echo "Could not find a c++ compiler")
    sleep 3
    exit 1
}
trap on_error ERR

REPO_ROOT=$(git rev-parse --show-toplevel)
TARGET_OS="${1:-$($REPO_ROOT/scripts/get-os.sh 2>&1 >/dev/null)}"

# Determine TARGET_OS & compiler
COMPILER="compiler_not_found"

if [ $TARGET_OS = "windows" ]; then
    if command -v gcc >/dev/null; then
        COMPILER="mingw"
    else
        COMPILER="msvc"
    fi
elif command -v clang >/dev/null; then
    COMPILER="clang"
elif command -v gcc >/dev/null; then
    COMPILER="gcc"
fi

(>&2 echo "$COMPILER")