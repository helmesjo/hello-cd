#!/bin/bash

set -euxo pipefail

cd build
ctest -C Release --output-on-failure

$SHELL