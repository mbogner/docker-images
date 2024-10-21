#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 98
source ../_shared.sh || exit 99

docker pull alpine:3
build "openjdk-alpine-jre17" "$PWD" "mbopm/openjdk-alpine-jre" "jre17"
