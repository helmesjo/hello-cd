#!/bin/bash

set -euxo pipefail

# Clean up leftovers before exit (don't delete build image, it might be shared. I don't like this though!)
function cleanup {
    echo "Cleaning up leftovers..."
    docker rm $CONTAINER_ID
    docker rmi $ARTIFACT_ID
    sleep 3
}
trap cleanup EXIT

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMIT_HASH=$(git rev-parse --short HEAD)
CONTAINER_WDIR=//source

# Build environment
BUILD_IMAGE="build-image:"$COMMIT_HASH
docker build    --tag $BUILD_IMAGE \
                --file $DIR/Dockerfile.build .

# Create build container
CONTAINER_ID=$( docker create \
                --workdir $CONTAINER_WDIR \
                $BUILD_IMAGE ./scripts/build.sh \
                )

# Copy over source to working dir
docker cp   ./ $CONTAINER_ID:$CONTAINER_WDIR

# Compile source
docker start -i $CONTAINER_ID

# Create artifact
ARTIFACT_ID=$(  docker commit \
                $CONTAINER_ID \
                artifact:$COMMIT_HASH \
                )
docker save --output artifact_$COMMIT_HASH.tar $ARTIFACT_ID