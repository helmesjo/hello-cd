#!/bin/bash
set -euo pipefail

function on_error {
    (>&2 echo "Could not determine cmake toolchain")
    sleep 3
    exit 1
}
trap on_error ERR

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOOLCHAIN_DIR="$CURRENT_DIR/../cmake/toolchain"

OS="$($CURRENT_DIR/get-os.sh 2>&1 >/dev/null)"
ARCH="$($CURRENT_DIR/get-arch.sh 2>&1 >/dev/null)"
COMPILER="unknown"

if [ "$OS" == "linux" ]; then
    COMPILER="gcc"
elif [ "$OS" == "windows" ]; then
    COMPILER="msvc"
fi

TOOLCHAIN="$OS-$COMPILER-$ARCH"

# If toolchain doesn't exist
if [ ! -f "$TOOLCHAIN_DIR/$TOOLCHAIN.cmake" ]; then
    (>&2 echo "No toolchain found matching '$TOOLCHAIN.cmake'")
    on_error
fi

(>&2 echo "$TOOLCHAIN")