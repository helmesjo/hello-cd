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

TARGET_OS="$($SCRIPT_DIR/get-arg.sh "$ARGS" --target-os 2>&1 >/dev/null)"
TARGET_OS="${TARGET_OS:-"$($REPO_ROOT/scripts/get-os.sh 2>&1 >/dev/null)"}"

TARGET_ARCH="$($SCRIPT_DIR/get-arg.sh "$ARGS" --target-arch 2>&1 >/dev/null)"
TARGET_ARCH="${TARGET_ARCH:-x86_64}"

BUILD_SHARED="$($SCRIPT_DIR/get-arg.sh "$ARGS" --shared 2>&1 >/dev/null)"

INSTALL_DIR="$($SCRIPT_DIR/get-arg.sh "$ARGS" --install-dir 2>&1 >/dev/null)"
INSTALL_DIR="${INSTALL_DIR:-"./output"}"

TOOLCHAIN=$($REPO_ROOT/cmake/determine-toolchain.sh --target-os=$TARGET_OS --target-arch=$TARGET_ARCH 2>&1 >/dev/null)
BUILD_DIR="$REPO_ROOT/build"

# Make all environment variables from upstream conan packages available to current session
source "$REPO_ROOT/conan/activate-envars.sh"

BUILD_TYPE=`if [ -z "${BUILD_SHARED-}" ]; then echo "Static"; else echo "Shared"; fi`

echo -e "\n-- Building for '$TARGET_OS-$TARGET_ARCH-$CONFIG-$BUILD_TYPE' with toolchain '$TOOLCHAIN'..."

cmake -E make_directory $BUILD_DIR
# Generate
cmake -E chdir $BUILD_DIR \
    cmake .. -DCMAKE_BUILD_TYPE=$CONFIG -DBUILD_SHARED_LIBS=$BUILD_SHARED -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR -DDOWNLOAD_ENABLED=FALSE

# Build
cmake -E chdir $BUILD_DIR \
    cmake --build . --config $CONFIG

echo -e "\n-- Finished building for '$TARGET_OS-$TARGET_ARCH-$CONFIG-$BUILD_TYPE' with toolchain '$TOOLCHAIN'."

sleep 3