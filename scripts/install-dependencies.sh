#!/bin/bash
set -euo pipefail

function on_error {
    echo "Something failed..."
    sleep 5
    exit 1
}
trap on_error ERR

command -v conan >/dev/null 2>&1 || 
{ 
    echo -e "-- CONAN PACKAGE MANAGER is used to install dependencies\n - Please install with 'pip install conan'" 1>&2
    on_error
}

echo -e "\n-- Installing dependencies...\n"

# Add conan-community as remote. Needed until more packages are available in the official repository.
# Fails if already added. If so, just swollow error.
conan remote add conan_community https://api.bintray.com/conan/conan-community/conan >/dev/null || true

cmake -E make_directory build
cmake -E chdir build \
    conan install .. --build=missing

echo -e "\n-- Dependencies installed.\n"
sleep 2