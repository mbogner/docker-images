#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 99
source ../../_shared.sh || exit 98

# latest version see https://downloads.apache.org/kafka/
../../download.sh "https://downloads.apache.org/kafka/$KAFKA_VERSION/kafka_$KAFKA_SCALA_VERSION-$KAFKA_VERSION.tgz" kafka.tgz || exit 97

cp ../../downloads/kafka.tgz . || exit 96
docker build -t mbopm/kraft:local .
rm -f kafka.tgz
