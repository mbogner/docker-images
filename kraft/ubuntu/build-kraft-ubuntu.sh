#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 99
source ../../_shared.sh || exit 98

# latest version see https://downloads.apache.org/kafka/
VERSION="ubuntu_2.13-3.8.0"
../../download.sh "https://downloads.apache.org/kafka/3.8.0/kafka_2.13-3.8.0.tgz" kafka.tgz || exit 97

cp ../../downloads/kafka.tgz . || exit 96
build "kraft-ubuntu" "$DIR" "mbopm/kraft" "$VERSION" "" || exit 1
rm -f kafka.tgz