#!/bin/bash

set -euo pipefail
exec 3>&1

function cleanup {
    if [ "${CONTAINER_ID-}" ]; then
        docker rm -f $CONTAINER_ID
    fi
}

function on_error {
    echo "Failed to start GoCD agent '$AGENT_NAME'..."
    cleanup
    sleep 3
    exit 1
}
trap on_error ERR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT=$(git rev-parse --show-toplevel)

AGENT_NAME="gocd-agent"
SERVER_NAME="$(docker ps --filter name=gocd-server --format '{{.Names}}')"

if [ -z "${SERVER_NAME-}" ]; then
    echo -e "-- No container found with name containing 'gocd-server'.\n--- Make sure gocd-server is started."
    sleep 5
    exit 1
fi

SERVER_URL=${1:-"https://$SERVER_NAME:8154/go"}

DOCKERFILE=$DIR/agent/"Dockerfile"

# Build docker image for the gocd agent
IMAGE_ID=$($REPO_ROOT/docker/build-image.sh --file=$DOCKERFILE --tag="gocd-agent" 2>&1 >&3)

# Make sure network is started (used to enable communication by container-name)
NETWORK=$($REPO_ROOT/docker/start-network.sh 2>&1 >&3)

echo -e "\n-- Starting GoCD agent '$AGENT_NAME' & connecting it to network '$NETWORK' and server '$SERVER_NAME'...\n"

AUTO_REGISTER_KEY="29a6415d-cfe8-40c7-9c46-37cf5612c995"
AUTO_REGISTER_ENVIRONMENTS="linux"
# Start gocd-agent and forward socket (so that the host-docker engine can be invoked from inside)
# Git-repo is added to agent and used as clone-url (will change this to point to a docker http server)
CONTAINER_ID=$(docker run \
                    --detach \
                    --restart always \
                    --volume /$REPO_ROOT:/source \
                    --privileged \
                    --net $NETWORK \
                    --env GO_SERVER_URL=$SERVER_URL \
                    --env AGENT_AUTO_REGISTER_KEY=$AUTO_REGISTER_KEY \
                    --env AGENT_AUTO_REGISTER_ENVIRONMENTS=$AUTO_REGISTER_ENVIRONMENTS \
                    $IMAGE_ID \
)

# Join network as manager
$REPO_ROOT/docker/start-network.sh --join=$CONTAINER_ID

echo $CONTAINER_ID >&2
echo -e "\n-- GoCD agent '$AGENT_NAME' started & connected to network '$NETWORK' and server '$SERVER_NAME'\n"

sleep 5