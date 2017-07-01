#!/bin/bash

set -euo pipefail

function on_error {
    echo "Something failed..."
    $SHELL
}
trap on_error ERR

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$CURRENT_DIR/build.sh Debug
$CURRENT_DIR/build.sh Release
$CURRENT_DIR/build.sh RelWithDebInfo