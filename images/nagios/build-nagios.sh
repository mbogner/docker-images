#!/usr/bin/env bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../../_shared.sh
source ./shared.sh

# last param is the build target as this image has multiple targets - don't remove it
build "nagios" "$PWD" "mbopm/nagios" "$NAGIOS_VERSION" "latest" "nagios"
build "nagios-web" "$PWD" "mbopm/nagios-web" "$NAGIOS_VERSION" "latest" "nagios-web"
rm -f ./*.tgz
