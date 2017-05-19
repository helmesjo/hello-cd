#!/bin/bash

# Don't do below. If anything fails, we still need to clean up
#set -euxo pipefail

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
                $BUILD_IMAGE_NAME ./build.sh 

# Remove any previous artifacts
ARTIFACT_NAME=artifact_$COMMIT_HASH.tar
rm -f $ARTIFACT_NAME

# Copy over source to working dir
docker cp   ./ $CONTAINER_NAME:$CONTAINER_WDIR

# Compile source
docker start -i $CONTAINER_NAME

# Create artifact
ARTIFACT_IMAGE=$BUILD_IMAGE_NAME
docker commit $CONTAINER_NAME $ARTIFACT_IMAGE
docker save --output $ARTIFACT_NAME $ARTIFACT_IMAGE

# Clean up leftovers
docker rm $CONTAINER_NAME
docker rmi $ARTIFACT_IMAGE