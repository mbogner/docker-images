#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 98
source ../_shared.sh || exit 99

build "$PWD" "mbopm/docker-dind-temurin-alpine" "25.0.3-dind-alpine3.19-jdk21"
