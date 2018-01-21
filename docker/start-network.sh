#!/bin/bash

set -euo pipefail

function on_error {
    echo "Could not start network $NETWORK_NAME" >&2
    sleep 5
    exit 1
}
trap on_error ERR

NETWORK_NAME="hello-cd"

echo -e "\n-- Starting docker network '$NETWORK_NAME'..."

NETWORK_ID=$(docker network ls --quiet --filter name=$NETWORK_NAME)

# If network doesn't exist yet, start it
if [ -z "${NETWORK_ID-}" ]; then
    docker node ls >/dev/null 2>&1 || FAILED=$? || true
    if [ "${FAILED-}" ]; then
        echo -e "\n-- Initiating swarm and joining as manager...\n"
        docker swarm init
    fi

    NETWORK_ID=$(docker network create \
                                    --driver overlay \
                                    --attachable \
                                    $NETWORK_NAME \
                )
    
    echo -e "\n-- Docker network '$NETWORK_NAME' started.\n"
else
    echo -e "\n-- Docker network '$NETWORK_NAME' already started."
fi

# Container id/name passed is added as swarm managers
CONTAINER="${1:-}"
if [ "${CONTAINER-}" ]; then
    echo -e "\n-- Adding container '$CONTAINER' as manager to swarm.\n"
    SWARM_IP=$(docker node inspect self --format '{{ .Status.Addr  }}')
    JOIN_TOKEN=$(docker swarm join-token manager --quiet)
    
    docker exec $CONTAINER docker swarm join --token $JOIN_TOKEN $SWARM_IP:2377 >/dev/null

    echo -e "-- Container '$CONTAINER' added as manager to swarm.\n"
fi

echo $NETWORK_NAME >&2

sleep 2