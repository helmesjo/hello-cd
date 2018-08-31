#!/bin/bash

set -euo pipefail

function on_error {
    ARG="<no-flag>"
    if [ "${EXPECTED_ARG-}" ]; then
        ARG="$EXPECTED_ARG"
    fi

    (>&2 echo "Could not find value for flag '$ARG'")
    exit 1
}
trap on_error ERR

ARGS=${1:-}
EXPECTED_ARG="${2:-}"

for i in ${ARGS[@]}
do
   case "$i" in
        $EXPECTED_ARG=*)
            ARG="${i#*=}"
            (>&2 echo $ARG)
            exit 0
            ;;
        $EXPECTED_ARG)
            (>&2 echo 1)
            exit 0
            ;;
        *)
    esac
  shift
done