#!/bin/bash
set -euo pipefail

function on_error {
    echo "Failed to determine repository name..."
    sleep 3
    exit 1
}
trap on_error ERR

REPO_ROOT="$(git rev-parse --show-toplevel)"

source "$REPO_ROOT/repo.config"

echo "$REPO_NAME" >&2