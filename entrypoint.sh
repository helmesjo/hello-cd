#!/bin/bash

# Add user 'go' to group docker to give permission to call docker-command
gpasswd -a go docker

# Start docker daemon
service docker start

# Run default entrypoint for gocd-agent
./docker-entrypoint.sh