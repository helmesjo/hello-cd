#!/bin/bash

set -euxo pipefail

echo "Setting up server..."

YAML_CONFIG_VERSION=0.4.0
YAML_CONFIG_URL=https://github.com/tomzo/gocd-yaml-config-plugin/releases/download/$YAML_CONFIG_VERSION/yaml-config-plugin-$YAML_CONFIG_VERSION.jar

# Download yaml-plugin (used to poll remote pipeline configs)
mkdir -p /godata/plugins/external && \
apk --no-cache add curl && \
curl --location --fail $YAML_CONFIG_URL > /godata/plugins/external/yaml-config-plugin-$YAML_CONFIG_VERSION.jar && \
chown -R 1000 /godata/plugins

# Run default entrypoint for gocd-agent
./docker-entrypoint.sh