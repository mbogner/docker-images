#!/usr/bin/env bash
PROJECT_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT_DIR
DOWNLOADS_DIR="$PROJECT_ROOT_DIR/downloads"
export DOWNLOADS_DIR
DOWNLOADS_SCRIPT="$PROJECT_ROOT_DIR/download.sh"
export DOWNLOADS_SCRIPT

####################################################################################
# latest of kafka version see https://downloads.apache.org/kafka/
####################################################################################
KAFKA_SCALA_VERSION="2.13"
export KAFKA_SCALA_VERSION
KAFKA_VERSION="4.4.0"
export KAFKA_VERSION

####################################################################################
# latest of debezium version see https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/
####################################################################################
DEBEZIUM_VERSION="3.7.0.Final"
export DEBEZIUM_VERSION

echo "#############################################################################################################"
echo "# Environment settings:"
echo "# PROJECT_ROOT_DIR=$PROJECT_ROOT_DIR"
echo "# DOWNLOADS_SCRIPT=$DOWNLOADS_SCRIPT"
echo "# DOWNLOADS_DIR=$DOWNLOADS_DIR"
echo "# KAFKA_SCALA_VERSION=$KAFKA_SCALA_VERSION"
echo "# KAFKA_VERSION=$KAFKA_VERSION"
echo "# DEBEZIUM_VERSION=$DEBEZIUM_VERSION"
echo "#############################################################################################################"

function build {
  local BUILD_NAME=$1
  local BUILD_DIR=$2
  local IMAGE_NAME=$3
  local VERSION=$4
  local EXTRA_TAG=${5:-}
  local TARGET=${6:-}

  echo "#############################################################################################################"
  echo "# Build parameters:"
  echo "# BUILD_NAME=$BUILD_NAME"
  echo "# BUILD_DIR=$BUILD_DIR"
  echo "# IMAGE_NAME=$IMAGE_NAME"
  echo "# VERSION=$VERSION"
  echo "# EXTRA_TAG=$EXTRA_TAG"
  echo "# TARGET=$TARGET"
  echo "#############################################################################################################"
  echo "# in case a builder named $BUILD_NAME exists that you're not using anymore, you can remove it with:"
  echo "#     docker buildx rm $BUILD_NAME"
  echo "# this can happen if a build failed"
  echo "#############################################################################################################"

  docker buildx create --name "$BUILD_NAME" --platform linux/amd64,linux/arm64 --driver docker-container || exit 1

  local BUILD_ARGS=(-t "${IMAGE_NAME}:${VERSION}")
  if [[ "" == "$EXTRA_TAG" ]]; then
    echo "# no extra tag"
  else
    echo "# extra tag: $EXTRA_TAG"
    BUILD_ARGS+=(-t "${IMAGE_NAME}:${EXTRA_TAG}")
  fi
  if [[ "" != "$TARGET" ]]; then
    echo "# target: $TARGET"
    BUILD_ARGS+=(--target "$TARGET")
  fi

  docker buildx build --builder "$BUILD_NAME" --platform linux/amd64,linux/arm64 \
    "${BUILD_ARGS[@]}" --push "${BUILD_DIR}" || exit 2

  echo "#############################################################################################################"
  echo "# done"
  echo "#############################################################################################################"

  # Clean up builder instance after use
  echo "cleanup buildx..."
  docker buildx rm "$BUILD_NAME"
}
