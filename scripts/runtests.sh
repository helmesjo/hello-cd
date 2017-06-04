#!/bin/bash

set -euxo pipefail

cd build
ctest --build-config Release --verbose --output-on-failure

sleep 3