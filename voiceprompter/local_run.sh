#!/usr/bin/env bash
set -euxo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
docker run -ti --rm -p 127.0.0.1:3000:3000 mbopm/voiceprompter:latest