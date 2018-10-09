#!/bin/bash

# Read here: https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
set -euo pipefail
exec 3>&1

function on_error {
    echo "Something failed..."
    sleep 5
    exit 1
}
trap on_error ERR

REPO_ROOT="$(git rev-parse --show-toplevel)"

SCRIPT_DIR="$REPO_ROOT/scripts"
ARGS="$@"

CONFIG="$($SCRIPT_DIR/get-arg.sh "$ARGS" --config "Release" 2>&1 >&3)"

TARGET_OS="$($SCRIPT_DIR/get-arg.sh "$ARGS" --target-os "$($SCRIPT_DIR/get-os.sh 2>&1 >&3)" 2>&1 >&3)"
TARGET_ARCH="$($SCRIPT_DIR/get-arg.sh "$ARGS" --target-arch "$($SCRIPT_DIR/get-arch.sh 2>&1 >&3)" 2>&1 >&3)"
BUILD_SHARED="$($SCRIPT_DIR/get-arg.sh "$ARGS" --shared 2>&1 >&3)"
INSTALL_DIR="$($SCRIPT_DIR/get-arg.sh "$ARGS" --install-dir "./output" 2>&1 >&3)"
COMPILER="$($SCRIPT_DIR/get-arg.sh "$ARGS" --compiler "$($SCRIPT_DIR/get-compiler.sh --target-os=$TARGET_OS 2>&1 >&3)" 2>&1 >&3)"
GENERATE_TEST_REPORT="$($SCRIPT_DIR/get-arg.sh "$ARGS" --generate-test-reports "FALSE" 2>&1 >&3)"

TOOLCHAIN=$($REPO_ROOT/cmake/determine-toolchain.sh  --compiler=$COMPILER --target-os=$TARGET_OS --target-arch=$TARGET_ARCH 2>&1 >/dev/null)
BUILD_DIR="$REPO_ROOT/build"

# Make all environment variables from upstream conan packages available to current session
source "$REPO_ROOT/conan/activate-envars.sh"

BUILD_TYPE=`if [ -z "${BUILD_SHARED-}" ]; then echo "Static"; else echo "Shared"; fi`

echo -e "\n-- Building for '$TARGET_OS-$TARGET_ARCH-$CONFIG-$BUILD_TYPE' with toolchain '$TOOLCHAIN'..."

cmake -E make_directory $BUILD_DIR
# Generate
cmake -E chdir $BUILD_DIR \
    cmake .. -DCMAKE_BUILD_TYPE=$CONFIG -DBUILD_SHARED_LIBS=$BUILD_SHARED -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR -DDOWNLOAD_ENABLED=FALSE -DTESTING_OUTPUT_JUNIT_REPORT=$GENERATE_TEST_REPORT

# Build
cmake -E chdir $BUILD_DIR \
    cmake --build . --config $CONFIG

echo -e "\n-- Finished building for '$TARGET_OS-$TARGET_ARCH-$CONFIG-$BUILD_TYPE' with toolchain '$TOOLCHAIN'."

sleep 3