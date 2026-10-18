#!/usr/bin/env bash
set -euxo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../_shared.sh

# upstream commit is pinned in Dockerfile - tag = short commit hash + number of applied patches, e.g. 99e08a0-p2
COMMIT="$(sed -n 's/^ARG VOICEPROMPTER_COMMIT=//p' Dockerfile)"
[[ -n "$COMMIT" ]]
PATCH_COUNT="$(find patches -maxdepth 1 -name '*.patch' | wc -l | tr -d ' ')"
VERSION="${COMMIT:0:7}-p${PATCH_COUNT}"

docker pull node:26-alpine
build "voiceprompter" "$PWD" "mbopm/voiceprompter" "$VERSION" "latest"
