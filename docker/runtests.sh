#!/bin/bash

set -euxo pipefail

function cleanup {
    sleep 3
}
trap cleanup EXIT

COMMIT_HASH=$(git rev-parse --short HEAD)
DOCKER_REPO="localhost:5000"
IMAGE_TAG=$DOCKER_REPO/"hello-cd:"$COMMIT_HASH

docker run  --rm \
            $IMAGE_TAG \
            ./scripts/runtests.sh