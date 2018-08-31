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

if [ -z "${ARGS-}" ]; then
    (>&2 echo "No arguments forwarded. In caller, do: 'get-arg.sh \"\$@\" --flag'")
    on_error
fi

EXPECTED_ARG="${2:-}"

if [ -z "${EXPECTED_ARG-}" ]; then
    (>&2 echo "Must pass name of expected flag, eg: 'get-arg.sh --flag'")
    on_error
fi

for i in ${ARGS[@]}
do
   case "$i" in
        $EXPECTED_ARG=*)
            ARG="${i#*=}"
            if [ -z "${EXPECTED_ARG-}" ]; then
                on_error
            else
                (>&2 echo $ARG)
                exit 0
            fi
            ;;
        *)
    esac
  shift
done

on_error