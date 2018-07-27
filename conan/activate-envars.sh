#!/bin/bash

set -euo pipefail

function on_error {
    echo "Something failed..."
    sleep 5
}
trap on_error ERR

REPO_ROOT="$(git rev-parse --show-toplevel)"
ACTIVATE_FILE="$REPO_ROOT/build/activate.sh"

echo -e "\n-- Activating environment variables from conan package dependencies..."
if [ -e $ACTIVATE_FILE ]
then
    # Make available all environment variables from upstream conan packages
    old_setting=${-//[^u]/}
    set +u
    source $ACTIVATE_FILE
    if [[ -n "$old_setting" ]]; then set -u; fi
    echo -e "-- Environment variables now available.\n"
else
    echo -e "-- Could not find conan activation file. Did you forget to add 'virtualenv' generator in conanfile.txt?\n---- Expected file: $ACTIVATE_FILE\n"
fi