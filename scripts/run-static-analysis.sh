#!/bin/bash

# Read here: https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
set -euo pipefail

function on_error {
    echo "Something failed..."
    sleep 5
    exit 1
}
trap on_error ERR

REPO_ROOT="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="$REPO_ROOT/scripts"
ARGS="$@"

CONFIG="$($SCRIPT_DIR/get-arg.sh "$ARGS" --config 2>&1 >/dev/null)"
CONFIG="${CONFIG:-Release}"

BUILD_DIR="$REPO_ROOT/build"

if [ ! -d "$BUILD_DIR" ]; then
    echo -e "-- Build directory not found at '$BUILD_DIR'\n - Please first build project with './scripts/build.sh'" 1>&2
    on_error
fi

echo -e "\n-- Running static analysis for build '$CONFIG'..."

cmake -E chdir $BUILD_DIR \
    cmake --build . --target static_analysis_all --config $CONFIG

echo -e "\n-- Finished running static analysis for build '$CONFIG'."

sleep 3