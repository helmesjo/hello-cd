#!/bin/bash

set -euxo pipefail

echo "Setting up docker..."

# Create group docker if not exists
getent group docker || groupadd docker

# Add user 'go' to group docker to give permission to call docker-command
usermod -a -G docker go

# Setup remapping for go-user & group. Makes sure all dind-containers run with user-id 1000:65536 (0 in container will be 1000 on host/mounted volume)
# See here: https://docs.docker.com/engine/security/userns-remap/
sed -ie 's/go:.*:.*/go:1000:65536/g' /etc/subuid
sed -ie 's/go:.*:.*/go:1000:65536/g' /etc/subgid

# Use storage driver "vfs", with lower performance but guarantees to work correctly with dind
# Also map go user- & group ID (created in gocd dockerfile) to root inside dind-container (so that files created inside dind container has correct permissions)
mkdir -p /etc/docker/ && echo "{\"storage-driver\":\"vfs\",\"userns-remap\":\"go:go\"}" > /etc/docker/daemon.json

# Restart docker daemon
service docker start
service docker restart

echo "Done setting up docker."

# Run default entrypoint for gocd-agent
./docker-entrypoint.sh