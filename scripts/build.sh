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

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOOLCHAIN=$($CURRENT_DIR/determine-toolchain.sh $ARCH 2>&1 >/dev/null)
TOOLCHAIN_DIR="$CURRENT_DIR/../cmake/toolchain"
BUILD_DIR="$CURRENT_DIR/../build"

# Install dependencies
$CURRENT_DIR/install-dependencies.sh $CONFIG $ARCH

echo "Building for '$CONFIG $ARCH' with toolchain '$TOOLCHAIN'..."
cmake -E make_directory $BUILD_DIR
# Generate
cmake -E chdir $BUILD_DIR \
    cmake .. -DCMAKE_BUILD_TYPE=$CONFIG -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_DIR/$TOOLCHAIN.cmake" -DCMAKE_INSTALL_PREFIX=output -DDOWNLOAD_ENABLED=FALSE

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