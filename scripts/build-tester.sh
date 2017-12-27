#!/bin/bash

set -euo pipefail

function on_error {
    echo "Something failed..."
    $SHELL
}
trap on_error ERR

# Read argument
ARCH="${1:-x86}"

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$CURRENT_DIR/build.sh Debug $ARCH
$CURRENT_DIR/build.sh Release $ARCH