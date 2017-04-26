#!/bin/bash

set -euxo pipefail

# Get the current working directory and add slash to beginning (to handle windows-inconsistencies)
CURRENT_WDIR=/$(pwd)
CONTAINER_WDIR=//tmp

docker run --volume=$CURRENT_WDIR:$CONTAINER_WDIR --workdir=$CONTAINER_WDIR build-image ./runtests.sh