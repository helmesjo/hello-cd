#!/bin/bash

# Read here: https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
set -euxo pipefail

# Read first argument, but default to Release if none supplied. 
CONFIG="${1:-Release}"

echo Building config: $CONFIG

mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=$CONFIG ..
cmake --build . --config $CONFIG
ctest --build-config $CONFIG --verbose --output-on-failure

sleep 3