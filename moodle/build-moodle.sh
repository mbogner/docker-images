#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}" || exit 99
source ../_shared.sh || exit 98

docker pull php:8.3-apache
build "moodle" "$DIR" "mbopm/moodle" "5.2" "latest" || exit 1
