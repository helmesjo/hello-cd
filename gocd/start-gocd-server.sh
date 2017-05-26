#!/bin/bash

set -euxo pipefail

function onExit {
    $SHELL
}
trap onExit EXIT

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CONFIG_FILE="cruise-config.xml"
DOCKERFILE="Dockerfile.gocd-server"
SERVER_IMAGE="gocd-server"

echo "Starting gocd-server..."

# Build docker image for the gocd-agent
docker build    --tag $SERVER_IMAGE \
                --file $DIR/$DOCKERFILE .

# Start gocd-agent and forward socket (so that the host-docker engine can be invoked from inside)
docker run  --detach \
            --volume /$DIR/$CONFIG_FILE:/godata/config/$CONFIG_FILE \
            --publish 8153:8153 \
            --publish 8154:8154 \
            $SERVER_IMAGE

echo "Server started!"