#!/bin/bash

set -euxo pipefail

function onExit {
    $SHELL
}
trap onExit EXIT

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DOCKERFILE="Dockerfile.gocd-agent"
AGENT_IMAGE="gocd-agent"

echo "Starting gocd-agent..."

# Build docker image for the gocd-agent
docker build    --tag $AGENT_IMAGE \
                --file $DIR/$DOCKERFILE .

# Try to find running server, else ask for ip
SERVER_NAME="gocd-server"
SERVER_URL=https://$(docker inspect --format='{{(index (index .NetworkSettings.IPAddress))}}' $SERVER_NAME):$(docker inspect --format='{{(index (index .NetworkSettings.Ports "8154/tcp") 0).HostPort}}' $SERVER_NAME)/go 

if [ -z ${SERVER_URL+x} ]
then
    read -p "Server ip: " ip
    SERVER_URL="https://$ip:8154/go"
fi

AUTO_REGISTER_KEY="29a6415d-cfe8-40c7-9c46-37cf5612c995"
AUTO_REGISTER_ENVIRONMENTS="docker"
# Start gocd-agent and forward socket (so that the host-docker engine can be invoked from inside)
docker run  --detach \
            --rm \
            --volume //var/run/docker.sock://var/run/docker.sock \
            --env GO_SERVER_URL=$SERVER_URL \
            --env AGENT_AUTO_REGISTER_KEY=$AUTO_REGISTER_KEY \
            --env AGENT_AUTO_REGISTER_ENVIRONMENTS=$AUTO_REGISTER_ENVIRONMENTS \
            $AGENT_IMAGE

echo "Agent started!"