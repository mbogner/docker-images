#!/usr/bin/env bash
# Builds both images from this Dockerfile: mbopm/kraft (target kraft) and mbopm/kafka-connect (target connect).
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../../../_shared.sh

# latest version see https://downloads.apache.org/kafka/ and
# https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/ (pins in _shared.sh)
VERSION="$KAFKA_SCALA_VERSION-$KAFKA_VERSION-alpine"
KAFKA_FILE="kafka_$KAFKA_SCALA_VERSION-$KAFKA_VERSION.tgz"
DEBEZIUM_FILE="debezium-connector-postgres-$DEBEZIUM_VERSION-plugin.tar.gz"
$DOWNLOADS_SCRIPT "https://downloads.apache.org/kafka/$KAFKA_VERSION/$KAFKA_FILE" "$KAFKA_FILE"
$DOWNLOADS_SCRIPT "https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/$DEBEZIUM_VERSION/$DEBEZIUM_FILE" "$DEBEZIUM_FILE"

trap 'rm -f kafka.tgz debezium-connector-postgres.tar.gz' EXIT
cp "$DOWNLOADS_DIR/$KAFKA_FILE" ./kafka.tgz
cp "$DOWNLOADS_DIR/$DEBEZIUM_FILE" ./debezium-connector-postgres.tar.gz

docker pull mbopm/corretto:jre25-alpine
build "kafka-alpine" "$DIR" "mbopm/kafka" "$VERSION" "latest" "kraft"
build "kafka-connect-alpine" "$DIR" "mbopm/kafka-connect" "$VERSION" "latest" "connect"
