#!/bin/bash
set -euo pipefail

function on_error {
    echo -e "\n-- Dependencies NOT installed.\n"
    sleep 3
    exit 1
}
trap on_error ERR

command -v conan >/dev/null 2>&1 || 
{ 
    echo -e "-- CONAN PACKAGE MANAGER is used to install dependencies\n - Please install with 'pip install conan'" 1>&2
    on_error
}

CONFIG="${1:-Release}"
ARCH="${2:-x86_64}"

REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$($REPO_ROOT/scripts/get-reponame.sh 2>&1)

OS="$($REPO_ROOT/scripts/get-os.sh 2>&1 >/dev/null)"
PROFILE="$REPO_ROOT/conan/profile-$OS.txt"
BUILD_DIR="$REPO_ROOT/build"

SERVER_NAME="${REPO_NAME}_conan-server"

echo -e "\n-- Installing dependencies for '$CONFIG $ARCH' with profile '$PROFILE'...n"

# Add conan-community as remote. Needed until more packages are available in the official repository.
# Fails if already added. If so, just swollow error.
conan remote add conan_community https://api.bintray.com/conan/conan-community/conan >/dev/null 2>&1 || true

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
    conan install .. --build=missing -s arch=$ARCH -s build_type=$CONFIG --profile=$PROFILE

echo -e "\n-- Dependencies installed.\n"
sleep 2