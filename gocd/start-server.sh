#!/bin/bash

set -euo pipefail

exec 3>&1

function cleanup {
    if [ "${CONTAINER_ID-}" ]; then
        docker rm -f $CONTAINER_ID
    fi
}

function on_error {
    echo "Could not start GoCD server '$SERVER_NAME'" >&2
    cleanup
    sleep 5
    exit 1
}
trap on_error ERR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$($REPO_ROOT/scripts/get-reponame.sh 2>&1)

SERVER_NAME="${REPO_NAME}_gocd-server"

CONFIG_FILE="cruise-config.xml"
DOCKERFILE=$DIR/server/"Dockerfile"

# Build docker image for the gocd server
IMAGE_ID=$($REPO_ROOT/docker/build-image.sh $DOCKERFILE "gocd-server" 2>&1 >&3)

# Make sure network is started (used to enable communication by container-name)
NETWORK=$($REPO_ROOT/docker/start-network.sh 2>&1 >&3)

# Copy server-config into mounted godata folder (don't want the actual config-file altered by the server)
GODATA_PATH=$DIR/_godata
CONFIG_DEST=$GODATA_PATH/config
mkdir -p $CONFIG_DEST
cp $DIR/$CONFIG_FILE $CONFIG_DEST/

# Replace branch in config to the current branch (defaults is master)
CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
cmake   -DFILE="$CONFIG_DEST/$CONFIG_FILE" \
        -DOLD="branch=\"master\"" \
        -DNEW="branch=\"$CURRENT_BRANCH\"" \
        -P "$REPO_ROOT/cmake/replace_in_file.cmake"

echo -e "\n-- Starting GoCD server '$SERVER_NAME' & connecting it to network '$NETWORK'...\n"

# Start gocd-agent and forward socket (so that the host-docker engine can be invoked from inside)
CONTAINER_ID=$(docker run  \
                        --detach \
                        --restart always \
                        --volume /$GODATA_PATH:/godata \
                        --volume /$REPO_ROOT:/source \
                        --net $NETWORK \
                        --publish 8153:8153 \
                        --publish 8154:8154 \
                        --name $SERVER_NAME \
                        $IMAGE_ID \
)

echo $CONTAINER_ID >&2
echo -e "\n-- GoCD server '$SERVER_NAME' started & connected to network '$NETWORK'\n"

sleep 5