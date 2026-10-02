#!/usr/bin/env bash
set -eu
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../_shared.sh
source _shared

# use build-openapi-generator-locally.sh to see the version
build "openapi-generator" "$PWD" "$IMAGE" "7.25.0" "latest"
