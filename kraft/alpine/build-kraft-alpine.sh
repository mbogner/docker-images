#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 99
source ../../_shared.sh || exit 98

# latest version see https://downloads.apache.org/kafka/
VERSION="alpine_$KAFKA_SCALA_VERSION-$KAFKA_VERSION"
../../download.sh "https://downloads.apache.org/kafka/$KAFKA_VERSION/kafka_$KAFKA_SCALA_VERSION-$KAFKA_VERSION.tgz" kafka.tgz || exit 97

cp ../../downloads/kafka.tgz . || exit 96
build "kraft-alpine" "$DIR" "mbopm/kraft" "$VERSION" "latest" || exit 1
rm -f kafka.tgz