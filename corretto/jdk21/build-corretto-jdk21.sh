#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../../_shared.sh

docker pull amazoncorretto:21-al2023
build "amazoncorretto-jdk21" "$PWD" "mbopm/corretto" "jdk21"
