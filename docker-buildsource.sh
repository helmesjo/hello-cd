#!/bin/bash

# Don't do below. If anything fails, we still need to clean up
#set -euxo pipefail

BUILD_IMAGE_NAME="build-image"
CONTAINER_NAME=container_$BUILD_IMAGE_NAME
ARTIFACT_NAME=artifact_$BUILD_IMAGE_NAME
CONTAINER_WDIR=//source

# Build environment
docker build    --tag $BUILD_IMAGE_NAME \
                --file ./Dockerfile.build .

# Create build container
docker create   --workdir $CONTAINER_WDIR \
                --name $CONTAINER_NAME \
                $BUILD_IMAGE_NAME ./build.sh 

# Copy over source to working dir
docker cp   ./ $CONTAINER_NAME:$CONTAINER_WDIR

# Compile source
docker start -i $CONTAINER_NAME

# Create artifact
docker commit $CONTAINER_NAME $ARTIFACT_NAME
docker save --output artifact.tar $ARTIFACT_NAME

# Clean up leftovers
docker rm $CONTAINER_NAME
docker rmi $ARTIFACT_NAME