#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../../_shared.sh

# see Dockerfile for version
docker pull eclipse-mosquitto:2
build "mosquito" "$PWD" "mbopm/mosquito" "2" "latest"
