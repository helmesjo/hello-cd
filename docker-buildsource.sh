#!/bin/bash

set -euxo pipefail

docker run --interactive --rm --volume=$(PWD):/tmp --workdir=/tmp build-image ./build.sh && echo "pass" || echo "fail"

exec $SHELL