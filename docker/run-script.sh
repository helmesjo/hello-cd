#!/bin/bash

set -euo pipefail

# Clean up leftovers before exit
function cleanup {
    echo "Cleaning up leftovers..."
    docker rm $CONTAINER_ID
    docker rmi $ARTIFACT_ID
    sleep 3
}
trap cleanup EXIT

if [[ $# -eq 0 ]] ; then
    echo "No argument supplied"
    exit 1
fi

SCRIPT=${1}
echo "Running script '$SCRIPT' inside container..."

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMIT_HASH=$(git rev-parse --short HEAD)
CONTAINER_WDIR=//source

# Build environment
BUILD_IMAGE="build:"$COMMIT_HASH
docker build    --tag $BUILD_IMAGE \
                --file $CURRENT_DIR/Dockerfile.build .

# Create build container & compile (create+start instead of run because of issues with logs)
CONTAINER_ID=$( docker create \
                --workdir $CONTAINER_WDIR \
                $BUILD_IMAGE sh -c "$SCRIPT" \
                )
docker start -i $CONTAINER_ID