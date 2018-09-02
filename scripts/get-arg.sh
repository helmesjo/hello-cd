#!/bin/bash

set -euo pipefail

function on_error {
    echo "Something failed while looking for flag '${EXPECTED_ARG-}' in '${ARGS-}'"
    exit 1
}
trap on_error ERR

ARGS="${1:-}"
EXPECTED_ARG="${2:-}"
FALLBACK_VALUE="${3:-}"

VALUE=${FALLBACK_VALUE:-}

for i in ${ARGS[@]}
do
    case "$i" in
        # --flag=value
        $EXPECTED_ARG=*)
            ARG="${i#*=}"
            VALUE=$ARG
            break
            ;;
        # --flag
        $EXPECTED_ARG)
            VALUE=1
            break
            ;;
        *)
    esac
done

# If a value was found, or if a fallback was specified, output it
( [ -z "$VALUE" ] || >&2 echo $VALUE )