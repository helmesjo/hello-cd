#!/bin/bash

# Read here: https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
set -euo pipefail

function on_error {
    echo "Something failed..."
    sleep 5
}
trap on_error ERR

# Read arguments
CONFIG="${1:-Release}"
ARCH="${2:-x86_64}"
BUILD_SHARED="${3:-FALSE}"

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git rev-parse --show-toplevel)"
TOOLCHAIN=$($REPO_ROOT/cmake/determine-toolchain.sh $ARCH 2>&1 >/dev/null)
BUILD_DIR="$REPO_ROOT/build"

# Make all environment variables from upstream conan packages available to current session
source "$REPO_ROOT/conan/activate-envars.sh"

echo "Building for '$CONFIG $ARCH' with toolchain '$TOOLCHAIN'..."
cmake -E make_directory $BUILD_DIR
# Generate
cmake -E chdir $BUILD_DIR \
    cmake .. -DCMAKE_BUILD_TYPE=$CONFIG -DBUILD_SHARED_LIBS=$BUILD_SHARED -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN -DCMAKE_INSTALL_PREFIX=output -DDOWNLOAD_ENABLED=FALSE

# Build
cmake -E chdir $BUILD_DIR \
    cmake --build . --config $CONFIG

# Run unit tests
cmake -E chdir $BUILD_DIR \
    ctest --build-config $CONFIG --parallel 2 --label-regex "unit" --output-on-failure

# Install
cmake -E chdir $BUILD_DIR \
    cmake --build . --target install --config $CONFIG

sleep 3