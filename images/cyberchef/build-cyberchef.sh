#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../../_shared.sh

# version see Dockerfile
docker pull alpine:3
docker pull nginx:alpine
build "cyberchef" "$PWD" "mbopm/cyberchef" "11.5.0" "latest"
