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

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OS="$($CURRENT_DIR/get-os.sh 2>&1 >/dev/null)"
PROFILE="$CURRENT_DIR/../conan/profile-$OS.txt"
BUILD_DIR="$CURRENT_DIR/../build"

echo -e "\n-- Installing dependencies for '$CONFIG $ARCH' with profile '$PROFILE'...n"

# Add conan-community as remote. Needed until more packages are available in the official repository.
# Fails if already added. If so, just swollow error.
conan remote add conan_community https://api.bintray.com/conan/conan-community/conan 2>&1 > /dev/null || true
# Add conan-server repository
conan remote add --insert 0 docker http://conan-server:9300 2>&1 > /dev/null || true
conan remote add --insert 1 local http://localhost:9300 2>&1 > /dev/null || true

cmake -E make_directory $BUILD_DIR

# Generate default profile. It is inherited inside profiles to autofill settings
conan profile new default --detect 2>&1 > /dev/null || true

# Install dependencies. Build if pre-built is missing.
cmake -E chdir $BUILD_DIR \
    conan install .. --build=missing -s arch=$ARCH -s build_type=$CONFIG --profile=$PROFILE

echo -e "\n-- Dependencies installed.\n"
sleep 2