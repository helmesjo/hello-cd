#!/bin/bash

set -euxo pipefail

# Clean up leftovers before exit
function cleanup {
    echo "Cleaning up leftovers..."
    sleep 3
    docker rmi $ARTIFACT_NAME
}
trap cleanup EXIT

# Get the current working directory and add slash to beginning (to handle windows-inconsistencies)
COMMIT_HASH=$(git rev-parse HEAD)
ARTIFACT_NAME=artifact:$COMMIT_HASH

docker load --input ./artifact_$COMMIT_HASH.tar

docker run  --rm \
            $ARTIFACT_NAME \
            ./scripts/runtests.sh