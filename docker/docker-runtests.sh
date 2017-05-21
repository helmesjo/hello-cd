#!/bin/bash

set -euxo pipefail

# Clean up leftovers before exit
function cleanup {
    echo "Cleaning up leftovers..."
    docker rmi $IMAGE_ID
    sleep 3
}
trap cleanup EXIT

COMMIT_HASH=$(git rev-parse --short HEAD)
ARTIFACT_NAME=artifact_$COMMIT_HASH.tar

# Load image and retain id
IMAGE_ID=$( docker image load \
            --input ./$ARTIFACT_NAME \
            )
# Filter out id from printed image-id (contains "human readable" noise). Gets all a-z, A-Z & 0-9 from end up until ':'.
IMAGE_ID=$([[ $IMAGE_ID =~ [a-zA-Z0-9]*$ ]] && echo ${BASH_REMATCH[0]})

docker run  --rm \
            $IMAGE_ID \
            ./scripts/runtests.sh