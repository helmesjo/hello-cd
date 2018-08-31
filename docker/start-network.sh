#!/bin/bash

set -euo pipefail

function on_error {
    echo "Could not start network $NETWORK_NAME" >&2
    sleep 5
    exit 1
}
trap on_error ERR

REPO_ROOT=$(git rev-parse --show-toplevel)
SCRIPT_DIR="$REPO_ROOT/scripts"
ARGS="$@"
# Container id/name passed is added as swarm managers
CONTAINER="$($SCRIPT_DIR/get-arg.sh "$ARGS" --join 2>&1 >/dev/null)"

NETWORK_NAME=$($REPO_ROOT/scripts/get-reponame.sh 2>&1)

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


if [ "${CONTAINER-}" ]; then
    echo -e "\n-- Adding container '$CONTAINER' to swarm as manager.\n"
    SWARM_IP=$(docker node inspect self --format '{{ .Status.Addr  }}')
    JOIN_TOKEN=$(docker swarm join-token manager --quiet)

    # Make sure docker is available & docker service has started before joining swarm as manager
    docker exec $CONTAINER sh -c "command -v docker >/dev/null && until docker ps >/dev/null 2>&1; do :; sleep 2; done"
    docker exec $CONTAINER sh -c "docker swarm join --token $JOIN_TOKEN $SWARM_IP:2377 >/dev/null"

    echo -e "-- Container '$CONTAINER' added to swarm as manager.\n"
fi

echo $NETWORK_NAME >&2

sleep 2