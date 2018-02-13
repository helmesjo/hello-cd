#!/bin/bash
set -euo pipefail

function on_error {
    echo "Something failed..."
    sleep 5
}
trap on_error ERR

CONFIG="${1:-Release}"
REPO_ROOT="$(git rev-parse --show-toplevel)"
BUILD_DIR="$REPO_ROOT/build"

echo "Running unit tests for build '$CONFIG'..."
cmake -E chdir $BUILD_DIR \
    ctest --build-config $CONFIG --parallel 2 --label-regex "unit" --output-on-failure

sleep 3
