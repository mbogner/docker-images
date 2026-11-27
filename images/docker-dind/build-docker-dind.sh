#!/usr/bin/env bash
# Builds all docker-in-docker images from the one Dockerfile (targets dind, jdk21, jdk25).
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../../_shared.sh

# see Dockerfile: keep in sync with its FROM docker:<DIND_VERSION>
DIND_VERSION="29.10.1-dind-alpine3.24"

docker pull "docker:$DIND_VERSION"
docker pull mbopm/corretto:jdk21-alpine
docker pull mbopm/corretto:jdk25-alpine
build "docker-dind-alpine" "$PWD" "mbopm/docker-dind" "$DIND_VERSION" "dind-alpine" "dind"
build "docker-dind-alpine-jdk21" "$PWD" "mbopm/docker-dind" "$DIND_VERSION-jdk21" "dind-alpine-jdk21" "jdk21"
build "docker-dind-alpine-jdk25" "$PWD" "mbopm/docker-dind" "$DIND_VERSION-jdk25" "dind-alpine-jdk25" "jdk25"
