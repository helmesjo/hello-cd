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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT_DIR="$(dirname "$DIR")"
REPO_NAME=$(basename `git rev-parse --show-toplevel`)
COMMIT_HASH=$(git rev-parse --short HEAD)
CONTAINER_WDIR=//source

# Expected args: 
# 1. Docker repository
# 2. Image-tag  (optional)
# 3. Dockerfile (optional)
DOCKER_REPO="${1:-"localhost:5000"}"
IMAGE_TAG="${2:-$REPO_NAME:$COMMIT_HASH}"
DOCKERFILE="${3:-$DIR/Dockerfile.build}"

IMAGE_ID=$($DIR/build-image.sh $DOCKERFILE $IMAGE_TAG 2>&1 >/dev/null)

echo "Pushing image '$IMAGE_TAG' to repository '$DOCKER_REPO'..."

# Create a new container and copy over built files
CONTAINER_ID=$( docker create \
                --workdir $CONTAINER_WDIR \
                $IMAGE_ID \
                )
docker cp $REPO_ROOT_DIR/build $CONTAINER_ID:$CONTAINER_WDIR

# Create, tag & push image (the end result, AKA artifact)
ARTIFACT_ID=$( docker commit    --message $COMMIT_HASH \
                                $CONTAINER_ID \
                                $DOCKER_REPO/$IMAGE_TAG \
                                )
docker push $DOCKER_REPO/$IMAGE_TAG