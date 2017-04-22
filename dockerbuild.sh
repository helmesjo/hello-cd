#!/bin/bash

docker run --rm --volume=$PWD:/tmp --workdir=/tmp build-image build.sh

$SHELL