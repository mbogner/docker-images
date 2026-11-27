#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../../../_shared.sh

docker pull alpine:3
build "openjdk-jdk21-alpine" "$PWD" "mbopm/openjdk" "jdk21-alpine"
