#!/bin/bash

set -euo pipefail

function on_error {
    echo "Something failed..."
    $SHELL
}
trap on_error ERR

./scripts/build.sh Debug
./build.sh Release
./build.sh RelWithDebInfo