#!/usr/bin/env bash
set -euxo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 98
source ../../_shared.sh || exit 99

../../download.sh "https://downloads.metabase.com/latest/metabase.jar" "metabase.jar" || exit 99
rm -f metabase.jar
cp ../../downloads/metabase.jar .