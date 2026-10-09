#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 99
source ../../_shared.sh || exit 98

# latest version see https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/
VERSION="alpine_$KAFKA_SCALA_VERSION-$KAFKA_VERSION-${DEBEZIUM_VERSION%.Final}"
PLUGIN_FILE="debezium-connector-postgres-$DEBEZIUM_VERSION-plugin.tar.gz"
$DOWNLOADS_SCRIPT "https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/$DEBEZIUM_VERSION/$PLUGIN_FILE" "$PLUGIN_FILE" || exit 97

cp "$DOWNLOADS_DIR/$PLUGIN_FILE" debezium-connector-postgres.tar.gz || exit 96
docker pull "mbopm/kafka-connect:alpine_$KAFKA_SCALA_VERSION-$KAFKA_VERSION"
build "kafka-connect-debezium-alpine" "$DIR" "mbopm/kafka-connect-debezium" "$VERSION" "latest" || exit 1
rm -f debezium-connector-postgres.tar.gz
