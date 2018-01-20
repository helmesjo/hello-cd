#!/bin/bash

set -euo pipefail

function on_error {
    echo "Could not start GoCD agent '$AGENT_NAME'" >&2
    sleep 5
    exit 1
}
trap on_error ERR

AGENT_NAME="gocd-agent"
SERVER_NAME="gocd-server"
SERVER_URL=${1:-"https://$SERVER_NAME:8154/go"}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT=$(git rev-parse --show-toplevel)

DOCKERFILE=$DIR/agent/"Dockerfile"

# Build docker image for the gocd agent
IMAGE_ID=$($REPO_ROOT/docker/build-image.sh $DOCKERFILE $AGENT_NAME 2>&1 >/dev/tty)

# Make sure network is started (used to enable communication by container-name)
NETWORK=$($REPO_ROOT/docker/start-network.sh 2>&1 >/dev/tty)

echo -e "\n-- Starting GoCD agent '$AGENT_NAME' & connecting it to network '$NETWORK'...\n"

AUTO_REGISTER_KEY="29a6415d-cfe8-40c7-9c46-37cf5612c995"
AUTO_REGISTER_ENVIRONMENTS="docker"
# Start gocd-agent and forward socket (so that the host-docker engine can be invoked from inside)
# Git-repo is added to agent and used as clone-url (will change this to point to a docker http server)
ID=$(docker run \
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

echo $ID >&2
echo -e "\n-- GoCD agent '$AGENT_NAME' started & connected to network '$NETWORK'\n"

sleep 5