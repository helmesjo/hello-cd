#!/bin/bash

set -euxo pipefail

# Clean up leftovers before exit
function cleanup {
    docker rm $CONTAINER_ID
    sleep 3
}
trap cleanup EXIT

if [[ $# -eq 0 ]] ; then
    echo "No argument supplied"
    exit 1
fi

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT_DIR="$(dirname "$CURRENT_DIR")"
REPO_NAME=$(basename `git rev-parse --show-toplevel`)
COMMIT_HASH=$(git rev-parse --short HEAD)
CONTAINER_WDIR=//source

# Expected args: 
# 1. Script
# 2. Dockerfile (optional)
# 3. Image-tag  (optional)
SCRIPT=${1}
DOCKERFILE="${2:-$CURRENT_DIR/Dockerfile.build}"
IMAGE_TAG="${3:-$REPO_NAME:build}"

# Make sure network is started (used to enable communication by container-name)
NETWORK=$($DIR/../docker/start-network.sh 2>&1)

IMAGE_ID=$($CURRENT_DIR/build-image.sh $DOCKERFILE $IMAGE_TAG 2>&1 >/dev/null)

echo "Running script '$SCRIPT' inside container..."

# Create build container & compile (create+start instead of run because of issues with logs)
CONTAINER_ID=$( docker create \
                --net $NETWORK \
                --volume /$REPO_ROOT_DIR:$CONTAINER_WDIR \
                --workdir $CONTAINER_WDIR \
                $IMAGE_ID sh -c "$SCRIPT" \
                )
docker start -i $CONTAINER_ID