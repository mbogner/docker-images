#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 98
source ../_shared.sh || exit 99

docker pull ubuntu:24.04
build "openjdk-ubuntu-jdk17" "$PWD" "mbopm/openjdk-ubuntu-jdk" "jdk17"
