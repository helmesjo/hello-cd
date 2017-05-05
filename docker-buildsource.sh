#!/bin/bash

set -euxo pipefail

# Get the current working directory and add slash to beginning (to handle windows-inconsistencies)
CURRENT_WDIR=/$(pwd)
CONTAINER_WDIR=//source

# Build environment
docker build \
        --tag=build-image \
        --file=./Dockerfile.build .

# Compile source
docker run \
        --rm \
        --volume=$CURRENT_WDIR:$CONTAINER_WDIR \
        --workdir=$CONTAINER_WDIR \
        build-image \
        ./build.sh