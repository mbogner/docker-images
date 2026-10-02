#!/usr/bin/env bash
set -eu
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../_shared.sh
source _shared

docker build -t "${IMAGE}:latest" .
docker run -ti --rm "${IMAGE}:latest"