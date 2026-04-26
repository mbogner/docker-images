#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 98
source ../_shared.sh || exit 99

# see Dockerfile for version
docker pull mbopm/docker-dind-alpine-healthcheck:29.4.1-dind-alpine3.23
build "docker-dind-openjdk-alpine-jdk25" "$PWD" "mbopm/docker-dind-openjdk-alpine" "29.4.1-dind-alpine3.23-jdk25" "latest"
