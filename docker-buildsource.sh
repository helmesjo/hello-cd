#!/bin/bash

set -euxo pipefail

echo "TESTING ECHO"

exit 1

docker run --interactive --rm --volume=$(PWD):/tmp --workdir=/tmp build-image ./build.sh && echo "pass" || echo "fail"