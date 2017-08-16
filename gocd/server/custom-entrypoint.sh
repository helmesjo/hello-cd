#!/bin/bash

set -euxo pipefail

echo "Setting up server..."

# Run default entrypoint for gocd-agent
./docker-entrypoint.sh