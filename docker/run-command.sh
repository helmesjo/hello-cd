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
    echo "Failed to run command '$COMMAND' inside container..."
    cleanup
    sleep 3
    exit 1
}
trap on_error ERR

# Check that argument was specified
if [[ $# -eq 0 ]] ; then
    echo "No arguments specified"
    exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(git rev-parse --show-toplevel)"
REPO_NAME=$($REPO_ROOT/scripts/get-reponame.sh 2>&1)
COMMIT_HASH=$(git rev-parse --short HEAD)
CONTAINER_WDIR=//source

COMMAND="${1}"

SCRIPT_DIR="$REPO_ROOT/scripts"
ARGS="$@"

DOCKERFILE="$($SCRIPT_DIR/get-arg.sh "$ARGS" --dockerfile "$DIR/build.Dockerfile" 2>&1 >&3)"
IMAGE_TAG="$($SCRIPT_DIR/get-arg.sh "$ARGS" --image-tag "$REPO_NAME:build" 2>&1 >&3)"

# Make sure network is started (used to enable communication by container-name)
NETWORK=$($REPO_ROOT/docker/start-network.sh 2>&1 >&3)

# Make sure image is built
IMAGE_ID=$($DIR/build-image.sh --file=$DOCKERFILE --tag=$IMAGE_TAG 2>&1 >&3)

echo -e "\n-- Running command '$COMMAND' inside container (Image: '$IMAGE_TAG' File: '$DOCKERFILE')...\n"

# Create build container & compile (create+start instead of run because of issues with logs)

# HACK: chmod below is to work around issues with gocd 'fetch artifact'-tasks which internally uses zip
# HACK: which in turn does not perserve the executable bit. So we manually add it to all folders & files in build (yuck).
FIX_EXECUTE_BITS="chmod -R +x $CONTAINER_WDIR/build >/dev/null 2>&1 || true"
CONTAINER_ID=$( docker create \
                        --tty \
                        --net $NETWORK \
                        --volume /$REPO_ROOT:$CONTAINER_WDIR \
                        --workdir $CONTAINER_WDIR \
                        $IMAGE_ID \
                        sh -c "$FIX_EXECUTE_BITS && $COMMAND" \
                )

docker start --interactive $CONTAINER_ID

echo -e "\n-- DONE running command '$COMMAND' inside container (Image: '$IMAGE_TAG' File: '$DOCKERFILE')...\n"

sleep 3