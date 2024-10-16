#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 98
source ../_shared.sh || exit 99

# see Dockerfile for version
docker pull 27.3.1-dind-alpine3.20
build "docker-dind-temurin-alpine-jdk21" "$PWD" "mbopm/docker-dind-temurin-alpine" "27.1.2-dind-alpine3.20-jdk21" "latest"
