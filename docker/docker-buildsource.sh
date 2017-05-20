#!/bin/bash

# Don't do below. If anything fails, we still need to clean up
set -euxo pipefail

# Clean up leftovers before exit
function cleanup {
    echo "Cleaning up leftovers..."
    docker rm $CONTAINER_NAME
    docker rmi $ARTIFACT_IMAGE
    docker rmi $BUILD_IMAGE_NAME
}
trap cleanup EXIT

COMMIT_HASH=$(git rev-parse HEAD)
CONTAINER_WDIR=//source

# Build environment
BUILD_IMAGE_NAME="build-image:"$COMMIT_HASH
docker build    --tag $BUILD_IMAGE_NAME \
                --file ./Dockerfile.build .

# Create build container
CONTAINER_NAME=container_build
docker create   --workdir $CONTAINER_WDIR \
                --name $CONTAINER_NAME \
                $BUILD_IMAGE_NAME ./scripts/build.sh

# Copy over source to working dir
docker cp   ./ $CONTAINER_NAME:$CONTAINER_WDIR

# Compile source
docker start -i $CONTAINER_NAME

# Create artifact
ARTIFACT_IMAGE=artifact:$COMMIT_HASH
docker commit $CONTAINER_NAME $ARTIFACT_IMAGE
docker save --output artifact_$COMMIT_HASH.tar $ARTIFACT_IMAGE