#!/bin/bash

# Read here: https://coderwall.com/p/fkfaqq/safer-bash-scripts-with-set-euxo-pipefail
set -euxo pipefail

function on_error {
    echo "Something failed..."
    sleep 5
}
trap on_error ERR

./scripts/build.sh Debug
cmake --build ./build --target coverage_all
cmake --build ./build --target install