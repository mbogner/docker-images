#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../../../_shared.sh

docker pull alpine:3.24
docker pull amazoncorretto:25-alpine3.24
build "amazoncorretto-jre25-alpine" "$PWD" "mbopm/corretto" "jre25-alpine" "jre-lts-alpine"
