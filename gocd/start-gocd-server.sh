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

mkdir -p $DIR/godata/config
cp $DIR/$CONFIG_FILE $DIR/godata/config/

# Start gocd-agent and forward socket (so that the host-docker engine can be invoked from inside)
docker run  --detach \
            --rm \
            --volume /$DIR/godata:/godata \
            --publish 8153:8153 \
            --publish 8154:8154 \
            --name $SERVER_IMAGE \
            $SERVER_IMAGE

echo "Server started!"