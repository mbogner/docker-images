#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 98
source ../_shared.sh || exit 99

# see Dockerfile for version
docker pull node:lts-alpine3.20
build "angular-builder-alpine" "$PWD" "mbopm/angular-builder-alpine" "lts-alpine3.20" "latest"
