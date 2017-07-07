#!/bin/bash

set -euxo pipefail

# Clean up leftovers before exit (don't delete build image, it might be shared. I don't like this though!)
function cleanup {
    echo "Cleaning up leftovers..."
    docker rm $CONTAINER_ID
    sleep 3
}
trap cleanup EXIT

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
                $BUILD_IMAGE sh -c "./scripts/run-coverage-analysis.sh && ./scripts/run-static-analysis.sh" \
                )
docker start -i $CONTAINER_ID

# Copy output back to host (should be optional)
docker cp $CONTAINER_ID:$CONTAINER_WDIR/build $CURRENT_DIR/../