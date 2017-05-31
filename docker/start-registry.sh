#!/bin/bash

set -euxo pipefail

function cleanup {
    echo "Cleaning up leftovers..."
    $SHELL
    sleep 3
}
trap cleanup EXIT

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REGISTRY_OUTDIR=$DIR/registry

mkdir -p $REGISTRY_OUTDIR

docker run  --name registry \
            --detach \
            --restart always \
            --publish 5000:5000 \
            --env REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=//registry \
            --volume /$REGISTRY_OUTDIR://registry \
            registry:2