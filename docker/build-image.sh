#!/bin/bash

set -euo pipefail

function on_error {
    echo "Could not build dockerfile $DOCKERFILE" >&2
    sleep 5
    exit 1
}
trap on_error ERR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$($REPO_ROOT/scripts/get-reponame.sh 2>&1)

SCRIPT_DIR="$REPO_ROOT/scripts"
ARGS="$@"

DOCKERFILE="$($SCRIPT_DIR/get-arg.sh "$ARGS" --file 2>&1 >/dev/null)"
DOCKERFILE="${DOCKERFILE:-$DIR/build.Dockerfile}"
IMAGE_NAME="$($SCRIPT_DIR/get-arg.sh "$ARGS" --name 2>&1 >/dev/null)"
IMAGE_NAME="${IMAGE_NAME:-"$REPO_NAME/$REPO_NAME:build"}"

echo -e "\n-- Building docker image '$IMAGE_NAME' from file '$DOCKERFILE'...\n"

# Build environment
docker build    --tag $IMAGE_NAME \
                --file $DOCKERFILE .

echo -e "\n-- Built docker image '$IMAGE_NAME' from file '$DOCKERFILE'.\n"

echo $IMAGE_NAME >&2

sleep 2