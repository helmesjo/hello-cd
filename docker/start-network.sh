#!/bin/bash

set -euo pipefail

function on_error {
    echo "Could not start network $NETWORK_NAME" >&2
    exit 1
}
trap on_error ERR

NETWORK_NAME="hello-cd"

echo -e "\n-- Starting docker network '$NETWORK_NAME'..."

NETWORK_ID=$(docker network ls --quiet --filter name=$NETWORK_NAME)

# If network doesn't exist yet, start it
if [ -z "${NETWORK_ID-}" ]; then
    NETWORK_ID=$(docker network create $NETWORK_NAME)
    echo -e "\n-- Docker network '$NETWORK_NAME' started.\n"
else
    echo -e "\n-- Docker network '$NETWORK_NAME' already started."
fi

echo $NETWORK_NAME >&2

sleep 2