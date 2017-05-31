#!/bin/bash

set -euxo pipefail

function onExit {
    $SHELL
}
trap onExit EXIT

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CONFIG_FILE="cruise-config.xml"
DOCKERFILE=$DIR/server/"Dockerfile"
SERVER_IMAGE="gocd-server"

echo "Starting gocd-server..."

# Build docker image for the gocd-agent
docker build    --tag $SERVER_IMAGE \
                --file $DOCKERFILE .

GODATA_PATH=$DIR/_godata
mkdir -p $GODATA_PATH/config
cp $DIR/$CONFIG_FILE $GODATA_PATH/config/

# Start gocd-agent and forward socket (so that the host-docker engine can be invoked from inside)
docker run  --detach \
            --rm \
            --volume /$GODATA_PATH:/godata \
            --publish 8153:8153 \
            --publish 8154:8154 \
            --name $SERVER_IMAGE \
            $SERVER_IMAGE

echo "Server started!"