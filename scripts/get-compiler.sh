#!/bin/bash
set -euo pipefail

function on_error {
    (>&2 echo "Could not find a c++ compiler")
    sleep 3
    exit 1
}
trap on_error ERR

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Determine OS & compiler
COMPILER="compiler_not_found"

if command -v gcc >/dev/null; then
    COMPILER="gcc"
elif command -v clang >/dev/null; then
    COMPILER="clang"
elif command -v cl >/dev/null; then
    COMPILER="msvc"
fi

(>&2 echo "$COMPILER")