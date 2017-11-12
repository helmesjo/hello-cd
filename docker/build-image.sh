#!/bin/bash

set -euo pipefail

# Clean up leftovers before exit (don't delete build image, it might be shared. I don't like this though!)
function cleanup {
    (>&2 echo "$IMAGE_ID")
    sleep 1
}
trap cleanup EXIT

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMMIT_HASH=$(git rev-parse --short HEAD)
REPO_NAME=$(basename `git rev-parse --show-toplevel`)

DOCKERFILE="${1:-$CURRENT_DIR/Dockerfile.build}"
IMAGE_TAG="${2:-$REPO_NAME:build}"

echo "Building image '$DOCKERFILE'..."

# Build environment
IMAGE_ID=$( docker build \
                --quiet \
                --tag $IMAGE_TAG \
                --file $DOCKERFILE .//docker
                )