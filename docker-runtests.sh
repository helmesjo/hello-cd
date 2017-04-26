#!/bin/bash

set -euxo pipefail

docker run --volume=$(PWD):/tmp --workdir=/tmp build-image ./runtests.sh && echo "pass" || echo "fail"