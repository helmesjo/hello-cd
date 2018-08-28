#!/bin/bash
set -euo pipefail

function on_error {
    (>&2 echo "Could not determine cmake toolchain")
    sleep 3
    exit 1
}
trap on_error ERR

REPO_ROOT=$(git rev-parse --show-toplevel)
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOOLCHAIN_DIR="$CURRENT_DIR/toolchain"

ARCH="${1:-"$($REPO_ROOT/scripts/get-arch.sh 2>&1 >/dev/null)"}"
OS="${2:-"$($REPO_ROOT/scripts/get-os.sh 2>&1 >/dev/null)"}"

COMPILER="$($REPO_ROOT/scripts/get-compiler.sh 2>&1 >/dev/null)"

TOOLCHAIN="$TOOLCHAIN_DIR/$OS-$COMPILER-$ARCH.cmake"

# If toolchain doesn't exist
if [ ! -f "$TOOLCHAIN" ]; then
    (>&2 echo "No toolchain found matching '$TOOLCHAIN'")
    on_error
fi

(>&2 echo "$TOOLCHAIN")