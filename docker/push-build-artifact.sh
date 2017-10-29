#!/bin/bash

set -euo pipefail

# Clean up leftovers before exit (don't delete build image, it might be shared. I don't like this though!)
function cleanup {
    docker rm $CONTAINER_ID
    docker rmi $ARTIFACT_ID

    (>&2 echo $IMAGE_TAG)

    sleep 3
}
trap cleanup EXIT

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT_DIR=$CURRENT_DIR/..
COMMIT_HASH=$(git rev-parse --short HEAD)
CONTAINER_WDIR=//source
REPO_NAME=$(basename `git rev-parse --show-toplevel`)

IMAGE_ID=$($CURRENT_DIR/build-image.sh 2>&1 >/dev/null)
DOCKER_REPO="localhost:5000"
IMAGE_TAG="${1:-$DOCKER_REPO/"$REPO_NAME:"$COMMIT_HASH}"

echo "Pushing image '$IMAGE_ID' to repository '$DOCKER_REPO'..."

# Create a new container and copy over built files
CONTAINER_ID=$( docker create \
                --workdir $CONTAINER_WDIR \
                $IMAGE_ID \
                )
docker cp $REPO_ROOT_DIR/build $CONTAINER_ID:$CONTAINER_WDIR

# Create, tag & push image (the end result, AKA artifact)
ARTIFACT_ID=$( docker commit    --message $COMMIT_HASH \
                                $CONTAINER_ID \
                                $IMAGE_TAG \
                                )
docker push $IMAGE_TAG