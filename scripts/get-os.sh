#!/bin/bash
set -euo pipefail

function on_error {
    (>&2 echo "Could not determine OS")
    sleep 3
    exit 1
}
trap on_error ERR

if [ "$(uname)" == "Darwin" ]; then
    # Mac
    OS="mac"    
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Linux
    OS="linux"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    # Win32
    OS="windows"
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    # Win64
    OS="windows"
fi

# If unset
if [ -z "${OS-}" ]; then
    on_error
fi

(>&2 echo "$OS")