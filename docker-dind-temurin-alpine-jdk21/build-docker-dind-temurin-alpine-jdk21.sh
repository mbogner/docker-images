#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 98
source ../_shared.sh || exit 99

# see Dockerfile for version
docker pull mbopm/docker-dind-alpine-healthcheck:28.1.1-dind-alpine3.21
build "docker-dind-temurin-alpine-jdk21" "$PWD" "mbopm/docker-dind-temurin-alpine" "28.0.4-dind-alpine3.21-jdk21" "latest"
