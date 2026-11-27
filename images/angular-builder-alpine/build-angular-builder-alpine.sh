#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../../_shared.sh

# see Dockerfile for version
docker pull node:lts-alpine
build "angular-builder-alpine" "$PWD" "mbopm/angular-builder-alpine" "lts-alpine" "latest"
