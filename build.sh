#!/bin/bash

set -eo pipefail

mkdir -p build
cd build
cmake ..
cmake --build . --config Release

$SHELL