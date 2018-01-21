#!/bin/bash
set -euo pipefail

function on_error {
    (>&2 echo "Could not determine repository name")
    sleep 3
    exit 1
}
trap on_error ERR

GIT_URL=$(git config --get remote.origin.url)
REPO_NAME=$(basename "${GIT_URL%.*}")

echo $REPO_NAME >&2