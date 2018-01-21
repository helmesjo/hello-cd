#!/bin/bash

set -euo pipefail

exec 3>&1

function cleanup {
    if [ "${CONTAINER_ID-}" ]; then
        docker rm $CONTAINER_ID
    fi
}

function on_error {
    echo "Could not start conan server '$SERVER_NAME'" >&2
    cleanup
    sleep 5
    exit 1
}
trap on_error ERR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT=$(git rev-parse --show-toplevel)

SERVER_NAME="conan-server"
DOCKERFILE="$DIR/server/Dockerfile"

# Make sure network is started (used to enable communication by container-name)
NETWORK=$($REPO_ROOT/docker/start-network.sh 2>&1 >&3)

# Build docker image for the conan server
IMAGE_ID=$($REPO_ROOT/docker/build-image.sh $DOCKERFILE $SERVER_NAME 2>&1 >&3)

# Copy server-config into to-be-mounted conan server-folder
DATA_DIR="$DIR/_data"
CONFIG_FILE="$DIR/server/server.conf"
CONFIG_CONAN_PATH="$DATA_DIR/.conan_server/"
mkdir -p $CONFIG_CONAN_PATH && cp $CONFIG_FILE $CONFIG_CONAN_PATH

echo -e "\n-- Starting conan server & connecting it to network '$NETWORK'...\n"

# Start conan server and mount _data sub-directory to conan storage path
CONTAINER_ID=$(docker run \
                        --detach \
                        --restart always \
                        --net $NETWORK \
                        --publish 9300:9300 \
                        --volume /$DATA_DIR:/var/lib/conan \
                        --name $SERVER_NAME \
                        --hostname $SERVER_NAME \
                        $IMAGE_ID \
)

echo $CONTAINER_ID >&2
echo -e "\n-- Conan server '$SERVER_NAME' started & connected to network '$NETWORK'\n"

sleep 5