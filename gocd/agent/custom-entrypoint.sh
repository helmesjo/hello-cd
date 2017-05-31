#!/bin/bash

set -euxo pipefail

echo "Setting up docker..."

# Create group docker if not exists
getent group docker || groupadd docker

# Add user 'go' to group docker to give permission to call docker-command
usermod -a -G docker go

# Make sure the group docker is associated with docker.sock
chgrp docker /var/run/docker.sock

# Restart docker daemon
service docker start

echo "Done setting up docker."

# Run default entrypoint for gocd-agent
./docker-entrypoint.sh