#!/bin/bash

set -euo pipefail
exec 3>&1

function on_error {
    echo "Failed to build dockerfile '${DOCKERFILE:-}'..."
    sleep 5
    exit 1
}
trap on_error ERR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$($REPO_ROOT/scripts/get-reponame.sh 2>&1)

SCRIPT_DIR="$REPO_ROOT/scripts"
ARGS="$@"

DOCKERFILE="$($SCRIPT_DIR/get-arg.sh "$ARGS" --file "$DIR/build.Dockerfile" 2>&1 >&3)"
IMAGE_NAME="$($SCRIPT_DIR/get-arg.sh "$ARGS" --tag "$REPO_NAME/$REPO_NAME:build" 2>&1 >&3)"

echo -e "\n-- Building docker image '$IMAGE_NAME' from file '$DOCKERFILE'...\n"

# Build environment
docker build    --tag $IMAGE_NAME \
                --file $DOCKERFILE .

echo -e "\n-- Built docker image '$IMAGE_NAME' from file '$DOCKERFILE'.\n"

echo $IMAGE_NAME >&2

sleep 2