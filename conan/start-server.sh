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
REPO_NAME=$($REPO_ROOT/scripts/get-reponame.sh 2>&1)

DOCKERFILE="$DIR/server/Dockerfile"

# Make sure network is started (used to enable communication by container-name)
NETWORK=$($REPO_ROOT/docker/start-network.sh 2>&1 >&3)

# Build docker image for the conan server
IMAGE_ID=$($REPO_ROOT/docker/build-image.sh --file=$DOCKERFILE --name="conan-server" 2>&1 >&3)

SERVER_NAME="${REPO_NAME}_conan-server"

# Copy server-config into to-be-mounted conan server-folder
DATA_DIR="$DIR/_data"
CONFIG_FILE_NAME="server.conf"
SOURCE_FILE="$DIR/server/server.conf"
DEST_PATH="$DATA_DIR/.conan_server/"
mkdir -p $DEST_PATH && cp $SOURCE_FILE $DEST_PATH
# Set correct hostname used by the server
sed -i "s/host_name:.*/host_name: $SERVER_NAME/g" "$DEST_PATH/$CONFIG_FILE_NAME"

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