#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 98
source ../_shared.sh || exit 99

# version see Dockerfile
build "cyberchef" "$PWD" "mbopm/cyberchef" "10.19.2" "latest" || exit 1
