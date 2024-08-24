#!/usr/bin/env bash

function build {
  local BUILD_NAME=$1
  local BUILD_DIR=$2
  local IMAGE_NAME=$3
  local VERSION=$4
  local EXTRA_TAG=$5

  echo "#############################################################################################################"
  echo "# build: BUILD_NAME=$BUILD_NAME BUILD_DIR=$BUILD_DIR, IMAGE_NAME=$IMAGE_NAME, VERSION=$VERSION, EXTRA_TAG=$EXTRA_TAG"
  echo "#############################################################################################################"
  echo "# in case a builder named $BUILD_NAME exists that you're not using anymore, you can remove it with:"
  echo "#     docker buildx rm $BUILD_NAME"
  echo "# this can happen if a build failed"

  docker buildx create --name "$BUILD_NAME" --platform linux/amd64,linux/arm64 --driver docker-container || exit 1

  if [[ "" == "$EXTRA_TAG" ]]; then
    echo "# no extra tag"
    docker buildx build --builder "$BUILD_NAME" --platform linux/amd64,linux/arm64 \
      -t "${IMAGE_NAME}:${VERSION}" --push "${BUILD_DIR}" || exit 2
  else
    echo "# extra tag: $EXTRA_TAG"
    docker buildx build --builder "$BUILD_NAME" --platform linux/amd64,linux/arm64 \
      -t "${IMAGE_NAME}:${VERSION}" -t "${IMAGE_NAME}:${EXTRA_TAG}" --push "${BUILD_DIR}" || exit 2
  fi


  echo "#############################################################################################################"
  echo "# done"
  echo "#############################################################################################################"

  # Clean up builder instance after use
  docker buildx rm "$BUILD_NAME"
}