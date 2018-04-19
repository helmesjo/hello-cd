#!/bin/bash
set -euo pipefail

function on_error {
    echo -e "\n-- Ports NOT opened.\n"
    sleep 3
    exit 1
}
trap on_error ERR

REPO_ROOT=$(git rev-parse --show-toplevel)
OS="$($REPO_ROOT/scripts/get-os.sh 2>&1 >/dev/null)"

# Linux required
if ! [ $OS == "linux" ]; then
    echo -e "-- This script can only be run on Linux, not $OS" 1>&2  
    on_error
fi

# Root required
if ! [ $(id -u) = 0 ]; then
    echo -e "-- This script must be run as root\n - Please run with 'sudo <shell> <script>'" 1>&2
    on_error
fi

# UFW required
command -v ufw >/dev/null 2>&1 || 
{ 
    echo -e "-- UFW is used to open ports on linux\n - Please install with 'sudo apt install ufw'" 1>&2
    on_error
}

echo -e "\n-- Opening ports required for docker swarm communication..."

ufw allow 2377/tcp
ufw allow 7946/tcp
ufw allow 7946/udp
ufw allow 4789/udp

ufw reload
# Perhaps not decireable to enable ufw automatically
#ufw enable

echo -e "\n-- Ports opened.\n"
sleep 2