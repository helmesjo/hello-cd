#!/bin/bash

set -euxo pipefail

function onExit {
    $SHELL
}
trap onExit EXIT

SERVER_NAME="conan-server"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DATA_DIR="$DIR/server/_data"

DOCKERFILE="$DIR/server/Dockerfile"
IMAGE_NAME="conan-server"

echo "Starting conan server..."

# Build docker image for the gocd-agent
docker build    --tag $IMAGE_NAME \
                --file $DOCKERFILE .

mkdir -p "$DATA_DIR"

# Start conan server and mount _data sub-directory to conan storage path
docker run  --detach \
            --rm \
            --publish 9300:9300 \
            --volume /$DATA_DIR:/var/lib/conan \
            --name $SERVER_NAME \
            $IMAGE_NAME

echo "Server started!"