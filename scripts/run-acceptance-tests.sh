#!/bin/bash
set -euo pipefail
exec 3>&1

function on_error {
    echo "Failed to run acceptance tests..."
    sleep 3
    exit 1
}
trap on_error ERR

REPO_ROOT="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="$REPO_ROOT/scripts"
ARGS="$@"

CONFIG="$($SCRIPT_DIR/get-arg.sh "$ARGS" --config "Release" 2>&1 >&3)"

BUILD_DIR="$REPO_ROOT/build"

if [ ! -d "$BUILD_DIR" ]; then
    echo -e "-- Build directory not found at '$BUILD_DIR'\n - Please first build project with './scripts/build.sh'"
    on_error
fi

echo -e "\n-- Running acceptance tests for build '$CONFIG'..."

cmake -E chdir $BUILD_DIR \
    ctest --label-regex "acceptance" --build-config $CONFIG --parallel 2 --output-on-failure

echo -e "\n-- Finished running acceptance tests for build '$CONFIG'."

sleep 3