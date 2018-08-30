#!/bin/bash

# Read here: https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
set -euo pipefail

function on_error {
    echo "Something failed..."
    sleep 3
    exit 1
}
trap on_error ERR

CONFIG="${1:-Debug}"
ARCH="${2:-x86_64}"

REPO_ROOT="$(git rev-parse --show-toplevel)"
BUILD_DIR="$REPO_ROOT/build"

if [ "$CONFIG" != "Debug" ]; then
    echo -e "-- Code coverage must be run in Debug mode.\n - Please run with './scripts/run-coverage-analysis.sh Debug'" 1>&2
    on_error
fi

if [ ! -d "$BUILD_DIR" ]; then
    echo -e "-- Build directory not found at '$BUILD_DIR'\n - Please first build project with './scripts/build.sh Debug' (Debug required for code coverage analysis)" 1>&2
    on_error
fi

echo "Running code coverage analysis for '$CONFIG $ARCH'..."

# Generate
cmake -E chdir $BUILD_DIR \
    cmake --build . --target coverage_all --config $CONFIG

sleep 3