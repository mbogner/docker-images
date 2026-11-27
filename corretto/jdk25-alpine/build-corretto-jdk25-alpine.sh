#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../../_shared.sh

docker pull amazoncorretto:25-alpine
build "amazoncorretto-jdk25-alpine" "$PWD" "mbopm/corretto" "jdk25-alpine" "jdk-lts-alpine"
