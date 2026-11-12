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

docker build --target nagios -t "mbopm/nagios:$NAGIOS_VERSION" -t mbopm/nagios:latest .
docker build --target nagios-web -t "mbopm/nagios-web:$NAGIOS_VERSION" -t mbopm/nagios-web:latest .
rm -f ./*.tgz
echo "built: mbopm/nagios:$NAGIOS_VERSION mbopm/nagios-web:$NAGIOS_VERSION"
echo "run with: NAGIOSADMIN_PASSWORD=... docker compose up"
