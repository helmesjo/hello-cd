#!/bin/bash

set -euxo pipefail

docker run --rm --volume=PWD:/tmp --workdir=/tmp build-image ./runtests.sh

$SHELL