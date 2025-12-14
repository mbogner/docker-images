#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 98
source ../_shared.sh || exit 99
mkdir -p tmp || exit 97

../download.sh "https://download.nextcloud.com/server/releases/latest.zip" "nextcloud.zip" || exit 90
cp ../downloads/nextcloud.zip ./tmp/ || exit 91

docker pull httpd:latest
build "nextcloud" "$PWD" "mbopm/nextcloud" "latest"
rm -rf ./tmp/