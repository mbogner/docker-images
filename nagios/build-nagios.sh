#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../_shared.sh
source ./shared.sh

../download.sh "https://go.nagios.org/get-core/$NAGIOS_VERSION" nagios.tgz
cp ../downloads/nagios.tgz .

../download.sh "https://go.nagios.org/get-nagios-plugins-$NAGIOS_PLUGIN_VERSION.tar.gz" nagios-plugins.tgz
cp ../downloads/nagios-plugins.tgz .

# last param is the build target as this image has multiple targets - don't remove it
build "nagios" "$PWD" "mbopm/nagios" "$NAGIOS_VERSION" "latest" "nagios"
build "nagios-web" "$PWD" "mbopm/nagios-web" "$NAGIOS_VERSION" "latest" "nagios-web"
rm -f ./*.tgz
