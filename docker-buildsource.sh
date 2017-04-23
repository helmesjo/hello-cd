#!/bin/bash

set -euxo pipefail

echo pwd
echo $(PWD)
docker run --rm --volume=$(PWD):/tmp --workdir=/tmp build-image ./build.sh

$SHELL