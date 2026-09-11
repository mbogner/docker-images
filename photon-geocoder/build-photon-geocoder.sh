#!/usr/bin/env bash
set -eu
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../_shared.sh

# https://github.com/komoot/photon/releases
PHOTO_VERSION=1.3.0
$DOWNLOADS_SCRIPT "https://github.com/komoot/photon/releases/download/$PHOTO_VERSION/photon-$PHOTO_VERSION.jar" photon.jar
cp ../downloads/photon.jar .

# see README.md for version
docker pull mbopm/openjdk-alpine-jdk:latest
build "photon-geocoder" "$PWD" "mbopm/photon-geocoder" "$PHOTO_VERSION" "latest"

rm -f photon.jar
