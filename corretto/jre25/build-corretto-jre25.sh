#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../../_shared.sh

docker pull amazoncorretto:25-al2023-headless
build "amazoncorretto-jre25" "$PWD" "mbopm/corretto" "jre25" "jre-lts"
