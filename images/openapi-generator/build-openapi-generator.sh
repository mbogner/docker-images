#!/usr/bin/env bash
set -eu
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../../_shared.sh
IMAGE=mbopm/openapi-generator

# pull base image
docker pull node:26-alpine

# the image has to be build so we see the installed version which is then parsed into VERSION variable
docker build -t "${IMAGE}:latest" .
VERSION=$(docker run --rm "${IMAGE}:latest" | grep -Eo '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1)
if [[ -z "${VERSION:-}" ]]; then
  echo "error: could not read the openapi-generator version from ${IMAGE}:latest" >&2
  exit 1
fi

# use build-openapi-generator-locally.sh to see the version
build "openapi-generator" "$PWD" "$IMAGE" "$VERSION" "latest"
