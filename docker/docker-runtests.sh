#!/bin/bash

#set -euxo pipefail

# Get the current working directory and add slash to beginning (to handle windows-inconsistencies)
COMMIT_HASH=$(git rev-parse HEAD)
ARTIFACT_NAME=artifact:$COMMIT_HASH

docker load --input ./artifact_$COMMIT_HASH.tar

docker run  --rm \
            $ARTIFACT_NAME \
            ./scripts/runtests.sh

docker rmi $ARTIFACT_NAME