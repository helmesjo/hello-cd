#!/bin/bash

set -euxo pipefail

function onExit {
    $SHELL
}
trap onExit EXIT

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CONFIG_FILE="cruise-config.xml"
DOCKERFILE=$CURRENT_DIR/server/"Dockerfile"
SERVER_IMAGE="gocd-server"

echo "Starting gocd-server..."

# Build docker image for the gocd-agent
docker build    --tag $SERVER_IMAGE \
                --file $DOCKERFILE .

# Copy server-config into mounted godata folder (don't want the actual config-file altered by the server)
GODATA_PATH=$CURRENT_DIR/_godata
mkdir -p $GODATA_PATH/config
cp $CURRENT_DIR/$CONFIG_FILE $GODATA_PATH/config/

GIT_ROOT=$(git rev-parse --show-toplevel)

# Start gocd-agent and forward socket (so that the host-docker engine can be invoked from inside)
docker run  --detach \
            --rm \
            --volume /$GODATA_PATH:/godata \
            --volume /$GIT_ROOT:/source \
            --publish 8153:8153 \
            --publish 8154:8154 \
            --name $SERVER_IMAGE \
            $SERVER_IMAGE

echo "Server started!"