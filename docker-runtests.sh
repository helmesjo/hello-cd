#!/bin/bash

#set -euxo pipefail

# Get the current working directory and add slash to beginning (to handle windows-inconsistencies)
BUILD_IMAGE_NAME="build-image"
ARTIFACT_IMAGE_NAME=artifact_$BUILD_IMAGE_NAME

docker load --input ./artifact.tar

docker run  --rm \
            $ARTIFACT_IMAGE_NAME \
            ./runtests.sh

docker rmi $ARTIFACT_IMAGE_NAME