#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${DIR}"
source ../_shared.sh

# see Dockerfile for version
docker pull timescale/timescaledb-ha:pg18
build "postgres-timescale-age-gis" "$PWD" "mbopm/postgres-timescale-age-gis" "pg18" "latest"
