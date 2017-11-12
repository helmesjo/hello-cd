#!/bin/bash

set -euxo pipefail

echo "Setting up docker..."

# Use storage driver "vfs", with lower performance but guarantees to work correctly with dind
mkdir /etc/docker/ && echo "{\"storage-driver\":\"vfs\"}" > /etc/docker/daemon.json

# Start docker daemon
service docker start

echo "Done setting up docker."

# Run default entrypoint for gocd-agent
./docker-entrypoint.sh