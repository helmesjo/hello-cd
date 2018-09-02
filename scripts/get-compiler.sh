#!/bin/bash
set -euo pipefail
exec 3>&1

function on_error {
    echo "Failed to find a C++ compiler..."
    sleep 3
    exit 1
}
trap on_error ERR

REPO_ROOT=$(git rev-parse --show-toplevel)
SCRIPT_DIR="$REPO_ROOT/scripts"
ARGS="$@"

TARGET_OS="$($SCRIPT_DIR/get-arg.sh "$ARGS" --target-os "$($SCRIPT_DIR/get-os.sh 2>&1 >&3)" 2>&1 >&3)"
HOST_OS="$($SCRIPT_DIR/get-arg.sh "$ARGS" --host-os "$($REPO_ROOT/scripts/get-os.sh 2>&1 >&3)" 2>&1 >&3)"

COMPILER="compiler_not_found"

if [ $TARGET_OS = "windows" ]; then
    if [ $HOST_OS == "linux" ]; then
        COMPILER="mingw"
    else
        COMPILER="msvc"
    fi
elif command -v clang >/dev/null; then
    COMPILER="clang"
elif command -v gcc >/dev/null; then
    COMPILER="gcc"
fi

echo "$COMPILER" >&2