#!/bin/bash
set -euo pipefail

function on_error {
    echo "Something failed..."
    sleep 5
}
trap on_error ERR

CONFIG="${1:-RelWithDebInfo}"
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Running acceptance tests for build '$CONFIG'..."
cmake -E chdir $CURRENT_DIR/../build \
    ctest  --label-regex "acceptance" --build-config $CONFIG --parallel 2 --output-on-failure
