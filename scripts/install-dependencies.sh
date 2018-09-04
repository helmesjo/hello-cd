#!/bin/bash
set -euo pipefail
exec 3>&1

function on_error {
    echo -e "\n-- Dependencies NOT installed.\n"
    sleep 3
    exit 1
}
trap on_error ERR

command -v conan >/dev/null 2>&1 || 
{ 
    echo -e "-- CONAN PACKAGE MANAGER is used to install dependencies\n - Please install with 'pip install conan'"
    on_error
}

REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$($REPO_ROOT/scripts/get-reponame.sh 2>&1)

SCRIPT_DIR="$REPO_ROOT/scripts"
ARGS="$@"

CONFIG="$($SCRIPT_DIR/get-arg.sh "$ARGS" --config "Release" 2>&1 >&3)"
TARGET_OS="$($SCRIPT_DIR/get-arg.sh "$ARGS" --target-os "$($SCRIPT_DIR/get-os.sh 2>&1 >&3)" 2>&1 >&3)"
TARGET_ARCH="$($SCRIPT_DIR/get-arg.sh "$ARGS" --target-arch "$($SCRIPT_DIR/get-arch.sh 2>&1 >&3)" 2>&1 >&3)"
HOST_OS="$($SCRIPT_DIR/get-arg.sh "$ARGS" --host-os "$($REPO_ROOT/scripts/get-os.sh 2>&1 >&3)" 2>&1 >&3)"
HOST_ARCH="$($SCRIPT_DIR/get-arg.sh "$ARGS" --host-arch "$($REPO_ROOT/scripts/get-arch.sh 2>&1 >&3)" 2>&1 >&3)"
COMPILER="$($SCRIPT_DIR/get-arg.sh "$ARGS" --compiler "$($SCRIPT_DIR/get-compiler.sh --target-os=$TARGET_OS 2>&1 >&3)" 2>&1 >&3)"

PROFILE="$($REPO_ROOT/conan/determine-profile.sh --compiler=$COMPILER --target-os=$TARGET_OS 2>&1 >&3)"
BUILD_DIR="$REPO_ROOT/build"

SERVER_NAME="${REPO_NAME}_conan-server"

echo -e "\n-- Installing dependencies for '$TARGET_OS-$TARGET_ARCH-$CONFIG' with profile '$PROFILE'..."

# Use a local cache for dependencies
export CONAN_USER_HOME=$BUILD_DIR

# Add bincrafters remote
conan remote add --insert 0 bincrafters https://api.bintray.com/conan/bincrafters/public-conan >/dev/null 2>&1 || true
# Add personal remote
conan remote add --insert 0 helmesjo https://api.bintray.com/conan/helmesjo/public-conan >/dev/null 2>&1 || true

# Add private repository (only if reachable)
if ping -w 1 -c 1 $SERVER_NAME >/dev/null 2>&1; then
    conan remote add --insert 0 docker http://$SERVER_NAME:9300 >/dev/null 2>&1 || true
else
    conan remote remove docker >/dev/null 2>&1 || true
fi

cmake -E make_directory $BUILD_DIR

# Generate default profile. It is inherited inside profiles to autofill settings
conan profile new default --detect >/dev/null 2>&1 || true

# Install dependencies. Build if pre-built is missing.
cmake -E chdir $BUILD_DIR \
    conan install .. --build=missing \
        -s arch=$TARGET_ARCH \
        -s build_type=$CONFIG \
        -s arch_build=$HOST_ARCH \
        -s os_build="${HOST_OS^}" \
        --profile=$PROFILE

echo -e "\n-- Installed dependencies for '$TARGET_OS-$TARGET_ARCH-$CONFIG' with profile '$PROFILE'.\n"
sleep 2