#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../../../_shared.sh

docker pull amazoncorretto:25-al2023
build "amazoncorretto-jdk25" "$PWD" "mbopm/corretto" "jdk25" "jdk-lts"
