#!/bin/bash
set -euo pipefail
exec 3>&1

function on_error {
    echo "Failed to determine cmake toolchain..."
    sleep 3
    exit 1
}
trap on_error ERR

REPO_ROOT=$(git rev-parse --show-toplevel)
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOOLCHAIN_DIR="$CURRENT_DIR/toolchain"

SCRIPT_DIR="$REPO_ROOT/scripts"
ARGS="$@"

TARGET_OS="$($SCRIPT_DIR/get-arg.sh "$ARGS" --target-os "$($SCRIPT_DIR/get-os.sh 2>&1 >&3)" 2>&1 >&3)"
TARGET_ARCH="$($SCRIPT_DIR/get-arg.sh "$ARGS" --target-arch "$($SCRIPT_DIR/get-arch.sh 2>&1 >&3)" 2>&1 >&3)"
COMPILER="$($SCRIPT_DIR/get-arg.sh "$ARGS" --compiler "$($SCRIPT_DIR/get-compiler.sh --target-os=$TARGET_OS 2>&1 >&3)" 2>&1 >&3)"

TOOLCHAIN="$TOOLCHAIN_DIR/$TARGET_OS-$COMPILER-$TARGET_ARCH.cmake"

# If toolchain doesn't exist
if [ ! -f "$TOOLCHAIN" ]; then
    "No toolchain found matching '$TOOLCHAIN'"
    on_error
fi

echo "$TOOLCHAIN" >&2