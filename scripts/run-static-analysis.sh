#!/bin/bash

# Read here: https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
set -euo pipefail

function on_error {
    echo "Something failed..."
    sleep 5
    exit 1
}
trap on_error ERR

CONFIG="${1:-Release}"
ARCH="${2:-x86_64}"

REPO_ROOT="$(git rev-parse --show-toplevel)"
BUILD_DIR="$REPO_ROOT/build"

if [ ! -d "$BUILD_DIR" ]; then
    echo -e "-- Build directory not found at '$BUILD_DIR'\n - Please first build project with './scripts/build.sh'" 1>&2
    on_error
fi

echo "Running static analysis for '$CONFIG $ARCH'..."

# Generate
cmake -E chdir $BUILD_DIR \
    cmake --build . --target static_analysis_all --config $CONFIG

sleep 3