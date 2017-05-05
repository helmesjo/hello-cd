#!/bin/bash

#set -euxo pipefail

BUILD_IMAGE="build-image"
CONTAINER_NAME=container_$BUILD_IMAGE
ARTIFACT_NAME=artifact_$BUILD_IMAGE
CURRENT_WDIR=/$(pwd)
CONTAINER_WDIR=//source

# Build environment
docker build    --tag $BUILD_IMAGE \
                --file ./Dockerfile.build .

# Compile source
docker run  --volume $CURRENT_WDIR:$CONTAINER_WDIR \
            --workdir $CONTAINER_WDIR \
            --name $CONTAINER_NAME \
            $BUILD_IMAGE \
            ./build.sh

# Create artifact
docker commit $CONTAINER_NAME $ARTIFACT_NAME
docker save --output artifact.tar $ARTIFACT_NAME

# Clean up leftovers
docker system prune --force