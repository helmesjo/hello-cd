#!/bin/bash
set -euo pipefail

function on_error {
    (>&2 echo "Could not determine conan profile")
    sleep 3
    exit 1
}
trap on_error ERR

REPO_ROOT=$(git rev-parse --show-toplevel)
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROFILE_DIR="$CURRENT_DIR/profile"

# Determine TARGET_OS & compiler
TARGET_OS="${1:-"$($REPO_ROOT/scripts/get-os.sh 2>&1 >/dev/null)"}"
COMPILER="$($REPO_ROOT/scripts/get-compiler.sh 2>&1 >/dev/null)"

PROFILE="$PROFILE_DIR/$TARGET_OS-$COMPILER.txt"

# If toolchain doesn't exist
if [ ! -f "$PROFILE" ]; then
    (>&2 echo "No toolchain found matching '$PROFILE'")
    on_error
fi

(>&2 echo "$PROFILE")