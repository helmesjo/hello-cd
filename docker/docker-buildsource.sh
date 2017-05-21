#!/bin/bash

# Don't do below. If anything fails, we still need to clean up
set -euxo pipefail

# Clean up leftovers before exit
function cleanup {
    echo "Cleaning up leftovers..."
    docker rm $CONTAINER_ID
    docker rmi $ARTIFACT_IMAGE
    docker rmi $BUILD_IMAGE_NAME
    sleep 3
}
trap cleanup EXIT

COMMIT_HASH=$(git rev-parse HEAD)
CONTAINER_WDIR=//source

# Build environment
BUILD_IMAGE_NAME="build-image:"$COMMIT_HASH
docker build    --tag $BUILD_IMAGE_NAME \
                --file ./Dockerfile.build .

# Create build container
CONTAINER_ID=$( docker create   --workdir $CONTAINER_WDIR \
                $BUILD_IMAGE_NAME ./scripts/build.sh \
                )

# Copy over source to working dir
docker cp   ./ $CONTAINER_ID:$CONTAINER_WDIR

# Compile source
docker start -i $CONTAINER_ID

# Create artifact
ARTIFACT_IMAGE=artifact:$COMMIT_HASH
docker commit $CONTAINER_ID $ARTIFACT_IMAGE
docker save --output artifact_$COMMIT_HASH.tar $ARTIFACT_IMAGE