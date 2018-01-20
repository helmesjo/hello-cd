#!/bin/bash

set -euo pipefail

function on_error {
    echo "Could not build dockerfile $DOCKERFILE" >&2
    sleep 5
    exit 1
}
trap on_error ERR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_NAME=$(basename `git rev-parse --show-toplevel`)

DOCKERFILE="${1:-$DIR/Dockerfile.build}"
IMAGE_NAME="${2:-$REPO_NAME:build}"

echo -e "\n-- Building docker image '$DOCKERFILE'...\n"

# Build environment
docker build    --tag $IMAGE_NAME \
                --file $DOCKERFILE .

echo -e "\n-- Built docker image '$IMAGE_NAME'\n"
echo $IMAGE_NAME >&2

sleep 2