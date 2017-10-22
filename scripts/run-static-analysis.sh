#!/bin/bash

# Read here: https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
set -euxo pipefail

function on_error {
    echo "Something failed..."
    sleep 5
}
trap on_error ERR

# Read first argument, but default to Release if none supplied. 
CONFIG="Debug"
echo "Running static analysis..."

cmake -E make_directory build
cd build
cmake .. -DCMAKE_BUILD_TYPE=$CONFIG -DCMAKE_INSTALL_PREFIX=output
cmake --build . --target static_analysis_all --config $CONFIG
cmake --build . --target install --config $CONFIG

sleep 3