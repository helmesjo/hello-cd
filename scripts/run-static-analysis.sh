#!/bin/bash

# Read here: https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
set -euo pipefail

function on_error {
    echo "Something failed..."
    sleep 5
}
trap on_error ERR

CONFIG="${1:-Release}"
ARCH="${2:-x86_64}"

REPO_ROOT="$(git rev-parse --show-toplevel)"
BUILD_DIR="$REPO_ROOT/build"

$REPO_ROOT/scripts/build.sh $CONFIG $ARCH

echo "Running code coverage analysis for '$CONFIG $ARCH'..."

# Generate
cmake -E chdir $BUILD_DIR \
    cmake --build . --target static_analysis_all --config $CONFIG
# Install result
cmake -E chdir $BUILD_DIR \
    cmake --build . --target install --config $CONFIG

sleep 3