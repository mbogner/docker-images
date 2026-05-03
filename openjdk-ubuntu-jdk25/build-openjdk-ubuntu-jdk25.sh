#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 98
source ../_shared.sh || exit 99

docker pull ubuntu:26.04
build "openjdk-ubuntu-jdk25" "$PWD" "mbopm/openjdk-ubuntu-jdk" "jdk25" "latest"
