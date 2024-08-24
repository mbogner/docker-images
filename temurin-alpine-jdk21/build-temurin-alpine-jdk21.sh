#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 98
source ../_shared.sh || exit 99

build "temurin-alpine-jdk21" "$PWD" "mbopm/temurin-alpine-jdk" "jdk21" "latest"
