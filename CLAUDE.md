# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Source for multi-arch Docker images published to Docker Hub under `mbopm/*` (https://hub.docker.com/repositories/mbopm). Each image lives in its own top-level directory with a `Dockerfile`, a `README.md`, and a `build-*.sh` script.

## Building images

Every image directory has a `build-<name>.sh` (or nested `alpine/`/`ubuntu/` variants with their own scripts). To build a single image:

```bash
cd <image-dir>
./build-<name>.sh
```

Build scripts always:
1. `cd` to their own directory.
2. `source ../_shared.sh` (or `../../_shared.sh` for nested variants like `kraft/alpine/`).
3. `docker pull` the upstream base image.
4. Call `build "<builder-name>" "$PWD" "<image>" "<version>" [extra-tag]` from `_shared.sh`.

`build` in `_shared.sh` runs `docker buildx create` + `docker buildx build --platform linux/amd64,linux/arm64 --push`, then removes the builder. Builds push directly to Docker Hub — there is no separate "build without push" path, so the user must be logged in (`docker login`) before running.

If a build fails and leaves a buildx builder behind, clean it manually: `docker buildx rm <builder-name>`.

## Downloads cache

`download.sh <url> <filename>` fetches into `./downloads/` (gitignored) and skips if the file already exists. Build scripts use this to cache plugin JARs, Kafka tarballs, etc., then copy from `downloads/` into the image build context. Some scripts (`sonarqube/build-sonarqube.sh`, `kraft/alpine/build-kraft-alpine.sh`) clean up copied artifacts from the build context after the build.

Shared Kafka version pins live in `_shared.sh` (`KAFKA_SCALA_VERSION`, `KAFKA_VERSION`) and are exported for all builds.

## Layout

- Top-level dirs = one image each (e.g. `sonarqube/`, `openjdk-alpine-jdk21/`, `cyberchef/`).
- Some images have OS variants as subdirs with their own build scripts (e.g. `kraft/alpine/`, `kafka-connect/ubuntu/`).
- `_compose/` holds standalone `docker-compose.yml` stacks (n8n, nextcloud, zabbix) — no build, just compose configs.
- `_shared.sh` — sourced helpers + shared version vars.
- `download.sh` — caching downloader.
- `downloads/` — shared download cache (gitignored).

## Versioning convention

Image tag = upstream version, optionally with OS prefix for variants (e.g. `alpine_2.13-4.2.0`, `jdk21`, `25.12.0.117093-community`). `latest` is passed as the extra-tag argument when desired.
