#!/bin/bash

set -euo pipefail

function on_error {
    echo "Could not start network $NETWORK_NAME" >&2
    sleep 5
    exit 1
}
trap on_error ERR

REPO_NAME=$(basename `git rev-parse --show-toplevel`)
NETWORK_NAME=$REPO_NAME

echo -e "\n-- Starting docker network '$NETWORK_NAME'..."

NETWORK_ID=$(docker network ls --quiet --filter name=$NETWORK_NAME)

# If network doesn't exist yet, start it
if [ -z "${NETWORK_ID-}" ]; then
    docker node ls >/dev/null 2>&1 || FAILED=$? || true
    if [ "${FAILED-}" ]; then
        echo -e "\n-- Initiating swarm and joining as manager...\n"
        docker swarm init --force-new-cluster >/dev/null
        echo -e "-- Swarm started."
    fi

    NETWORK_ID=$(docker network create \
                                    --driver overlay \
                                    --attachable \
                                    $NETWORK_NAME \
                )
    
    echo -e "\n-- Docker network '$NETWORK_NAME' started.\n"
else
    echo -e "-- Docker network '$NETWORK_NAME' already started."
fi

# Container id/name passed is added as swarm managers
CONTAINER="${1:-}"
if [ "${CONTAINER-}" ]; then
    echo -e "\n-- Adding container '$CONTAINER' to swarm as manager.\n"
    SWARM_IP=$(docker node inspect self --format '{{ .Status.Addr  }}')
    JOIN_TOKEN=$(docker swarm join-token manager --quiet)

    # Make sure docker is available & docker service has started before joining swarm as manager
    docker exec $CONTAINER command -v docker >/dev/null && until /etc/init.d/docker status >/dev/null; do :; sleep 2; done
    docker exec $CONTAINER docker swarm join --token $JOIN_TOKEN $SWARM_IP:2377 >/dev/null

    echo -e "-- Container '$CONTAINER' added to swarm as manager.\n"
fi

echo $NETWORK_NAME >&2

sleep 2