#!/bin/bash

set -euo pipefail

function on_error {
    echo "Could not stop network $NETWORK_NAME" >&2
    sleep 5
    exit 1
}
trap on_error ERR

REPO_ROOT=$(git rev-parse --show-toplevel)
NETWORK_NAME=$($REPO_ROOT/scripts/get-reponame.sh 2>&1)

echo -e "\n-- Stopping docker network '$NETWORK_NAME'..."

NETWORK_ID=$(docker network ls --quiet --filter name=$NETWORK_NAME)

# If network doesn't exist yet, start it
if [ -z "${NETWORK_ID-}" ]; then    
    echo -e "\n-- Docker network '$NETWORK_NAME' not running.\n"
else
    docker swarm leave --force 2>/dev/null || true
    docker network remove $NETWORK_NAME
    echo -e "-- Docker network '$NETWORK_NAME' stopped."
fi

sleep 2