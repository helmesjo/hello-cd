#!/bin/bash

set -euo pipefail

exec 3>&1

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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git rev-parse --show-toplevel)"
REPO_NAME=$($REPO_ROOT/scripts/get-reponame.sh 2>&1)
COMMIT_HASH=$(git rev-parse --short HEAD)
CONTAINER_WDIR=//source

# Expected args: 
# 1. Script
# 2. Dockerfile (optional)
# 3. Image-tag  (optional)
SCRIPT=${1}
DOCKERFILE="${2:-$DIR/Dockerfile.build}"
IMAGE_TAG="${3:-$REPO_NAME:build}"

# Make sure network is started (used to enable communication by container-name)
NETWORK=$($REPO_ROOT/docker/start-network.sh 2>&1 >&3)

# Make sure image is built
IMAGE_ID=$($DIR/build-image.sh $DOCKERFILE $IMAGE_TAG 2>&1 >&3)

echo -e "\n-- Running script '$SCRIPT' inside container (Image: '$IMAGE_TAG')...\n"

# Create build container & compile (create+start instead of run because of issues with logs)
CONTAINER_ID=$( docker create \
                        --tty \
                        --net $NETWORK \
                        --volume /$REPO_ROOT:$CONTAINER_WDIR \
                        --workdir $CONTAINER_WDIR \
                        $IMAGE_ID \
                        sh -c "$SCRIPT" \
                )

docker start --interactive $CONTAINER_ID

echo -e "\n-- DONE running script '$SCRIPT' inside container (Image: '$IMAGE_TAG')...\n"

sleep 3