#!/bin/bash

set -euo pipefail

# Clean up leftovers before exit
function cleanup {
    if [ "${CONTAINER_ID-}" ]; then
        docker rm $CONTAINER_ID
    fi
}
trap cleanup EXIT

function on_error {
    echo "Could not run script '$SCRIPT' inside container" >&2
    cleanup
    sleep 5
    exit 1
}
trap on_error ERR

# Check that argument was supplied
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
NETWORK=$($CURRENT_DIR/../docker/start-network.sh 2>&1 >/dev/tty)

# Make sure image is built
IMAGE_ID=$($CURRENT_DIR/build-image.sh $DOCKERFILE $IMAGE_TAG 2>&1 >/dev/tty)

echo -e "\n-- Running script '$SCRIPT' inside container (image (Image: '$IMAGE_TAG')...\n"

# Create build container & compile (create+start instead of run because of issues with logs)
CONTAINER_ID=$( docker create \
                --net $NETWORK \
                --volume /$REPO_ROOT_DIR:$CONTAINER_WDIR \
                --workdir $CONTAINER_WDIR \
                $IMAGE_ID sh -c "$SCRIPT" \
                )

docker start -i $CONTAINER_ID

echo -e "\n-- DONE running script '$SCRIPT' inside container (Image: '$IMAGE_TAG')...\n"