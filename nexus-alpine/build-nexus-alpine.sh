#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 98
source ../_shared.sh || exit 99

# see Dockerfile for version
docker pull mbopm/openjdk-alpine-jre:jre17
build "nexus-alpine" "$PWD" "mbopm/nexus-alpine" "3.73.0-12" "latest"
