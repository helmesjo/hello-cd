#!/bin/bash

set -euo pipefail

chown -R conan /var/lib/conan
su -c conan_server conan