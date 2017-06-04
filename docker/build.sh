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
BUILD_IMAGE="build:"$COMMIT_HASH
docker build    --tag $BUILD_IMAGE \
                --file $DIR/Dockerfile.build .

# Create build container & compile (create+start instead of run because of issues with logs)
CONTAINER_ID=$( docker create \
                --workdir $CONTAINER_WDIR \
                $BUILD_IMAGE ./scripts/build.sh \
                )
docker start -i $CONTAINER_ID

# Copy output back to host (should be optional)
docker cp $CONTAINER_ID:$CONTAINER_WDIR/output $DIR/..

# Create, tag & push image (the end result, AKA artifact)
DOCKER_REPO="localhost:5000"
IMAGE_TAG=$DOCKER_REPO/"hello-cd:"$COMMIT_HASH
ARTIFACT_ID=$( docker commit    --message $COMMIT_HASH \
                                $CONTAINER_ID \
                                $IMAGE_TAG \
                                )

docker push $IMAGE_TAG