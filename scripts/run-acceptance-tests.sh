#!/bin/bash
set -euo pipefail

function on_error {
    echo "Something failed..."
    sleep 3
    exit 1
}
trap on_error ERR

CONFIG="${1:-Release}"
REPO_ROOT="$(git rev-parse --show-toplevel)"
BUILD_DIR="$REPO_ROOT/build"

if [ ! -d "$BUILD_DIR" ]; then
    echo -e "-- Build directory not found at '$BUILD_DIR'\n - Please first build project with './scripts/build.sh'" 1>&2
    on_error
fi

echo "Running acceptance tests for build '$CONFIG'..."
cmake -E chdir $BUILD_DIR \
    ctest --label-regex "acceptance" --build-config $CONFIG --parallel 2 --output-on-failure

sleep 3