#!/bin/bash

# Read here: https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
set -euo pipefail

function on_error {
    echo "Something failed..."
    sleep 5
}
trap on_error ERR

# Read first argument, but default to Release if none supplied. 
CONFIG="${1:-RelWithDebInfo}"

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Building config '$CONFIG'..."
cmake -E make_directory build
# Generate
cmake -E chdir build \
    cmake .. -DCMAKE_BUILD_TYPE=$CONFIG -DCMAKE_INSTALL_PREFIX=output -DDOWNLOAD_ENABLED=FALSE

# Build
cmake -E chdir build \
    cmake --build . --config $CONFIG

# Run unit tests
cmake -E chdir build \
    ctest --build-config $CONFIG --parallel 2 --label-regex "unit" --output-on-failure

# Install
cmake -E chdir build \
    cmake --build . --target install --config $CONFIG

sleep 3