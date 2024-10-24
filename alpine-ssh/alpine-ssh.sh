#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 98
source ../_shared.sh || exit 99

docker pull alpine:3
build "alpine-ssh" "$PWD" "mbopm/alpine-ssh" "3" "latest"
