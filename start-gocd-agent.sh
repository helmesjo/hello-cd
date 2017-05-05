#!/bin/bash

set -euxo pipefail

DOCKERFILE="Dockerfile.gocd-agent"
AGENT_IMAGE="gocd-agent"
SERVER_URL="https://192.168.10.127:8154/go"

echo "Starting gocd-agent..."

# Build docker image for the gocd-agent
docker build    --tag $AGENT_IMAGE \
                --file ./$DOCKERFILE .

# Start gocd-agent and forward socket (so that the host-docker engine can be invoked from inside)
docker run  --detach \
            --volume //var/run/docker.sock://var/run/docker.sock \
            --env GO_SERVER_URL=$SERVER_URL \
            $AGENT_IMAGE

echo "Agent started!"