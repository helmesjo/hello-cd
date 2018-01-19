#!/bin/bash

set -euo pipefail

function on_error {
    echo "Could not start conan server '$SERVER_NAME'" >&2
    sleep 5
    exit 1
}
trap on_error ERR

SERVER_NAME="conan-server"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DOCKERFILE="$DIR/server/Dockerfile"
IMAGE_NAME="conan-server"

# Make sure network is started (used to enable communication by container-name)
NETWORK=$($DIR/../docker/start-network.sh 2>&1 >/dev/tty)

echo -e "\n-- Starting conan server, connecting it to network '$NETWORK'...\n"

# Build docker image for the conan-server
docker build    --tag $IMAGE_NAME \
                --file $DOCKERFILE .

# Copy server-config into to-be-mounted conan server-folder
DATA_DIR="$DIR/server/_data"
CONFIG_FILE="$DIR/server/server.conf"
CONFIG_CONAN_PATH="$DATA_DIR/.conan_server/"
mkdir -p $CONFIG_CONAN_PATH && cp $CONFIG_FILE $CONFIG_CONAN_PATH

# Start conan server and mount _data sub-directory to conan storage path

ID=$(docker run  --detach \
            --restart always \
            --net $NETWORK \
            --publish 9300:9300 \
            --volume /$DATA_DIR:/var/lib/conan \
            --name $SERVER_NAME \
            --hostname $SERVER_NAME \
            $IMAGE_NAME \
    )

echo $ID >&2
echo -e "\n-- Conan server '$SERVER_NAME' started & connected to network '$NETWORK'\n"

sleep 5