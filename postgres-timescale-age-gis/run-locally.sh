#!/usr/bin/env bash
set -e
docker run --name pg \
  -e POSTGRES_PASSWORD=postgres \
  -p "127.0.0.1:5432:5432" \
  --rm \
  mbopm/postgres-timescale-age-gis:latest
