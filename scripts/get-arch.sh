#!/bin/bash
set -euo pipefail

function on_error {
    echo "Could not determine architecture given: $(arch)"
    sleep 3
    exit 1
}
trap on_error ERR

if [ "$(arch)" == "x86_64" ]; then
    # 64-bit
    ARCH="x86_64"
else
    # 32-bit (guessing)
    ARCH="x86"
fi

# If unset
if [ -z "${ARCH-}" ]; then
    on_error
fi

echo "$ARCH" >&2