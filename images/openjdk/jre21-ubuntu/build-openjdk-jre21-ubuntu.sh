#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../../../_shared.sh

docker pull ubuntu:26.04
build "openjdk-jre21-ubuntu" "$PWD" "mbopm/openjdk" "jre21-ubuntu"
