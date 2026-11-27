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
2. `source ../_shared.sh` (or `../../../_shared.sh` for variants below `images/<family>/<variant>/`).
3. `docker pull` the upstream base image.
4. Call `build "<builder-name>" "$PWD" "<image>" "<version>" [extra-tag] [target]` from `_shared.sh`. `target` picks a stage of a multi-stage Dockerfile: `images/kafka/<os>/` builds `mbopm/kraft` (target `kraft`) and `mbopm/kafka-connect` (target `connect`, includes Debezium) from one Dockerfile with a shared Kafka stage.

`build` in `_shared.sh` runs `docker buildx create` + `docker buildx build --platform linux/amd64,linux/arm64 --push`, then removes the builder. Builds push directly to Docker Hub — there is no separate "build without push" path, so the user must be logged in (`docker login`) before running.

If a build fails and leaves a buildx builder behind, clean it manually: `docker buildx rm <builder-name>`.

## images/ batch builds

`images/` groups image families that are built in parallel. Images built on another `images/` image (e.g. `kafka/alpine` on `mbopm/corretto:jre25-alpine`) need their base listed in `BUILD_FIRST` at the top of `build.sh`. Layout: `images/<family>/<variant>/` with a `Dockerfile` and a `build-*.sh` (e.g. `images/corretto/jdk21/build-corretto-jdk21.sh`). Build scripts there `source ../../../_shared.sh`. The family `README.md` sits in `images/<family>/`.

`images/build.sh [-j <parallel>] [-m <max-age-hours>] [-f] [-y] [<path>...]` builds them in batches:
- `BUILD_FIRST` (array of globs on the build dir relative to `images/`, e.g. `"corretto/*" "openjdk/*"`) sets stages that run first, in that order. Every build of a stage must succeed before the next stage starts; builds within a stage run in parallel; unmatched builds form the last stage.
- Finds every `build-*.sh` at any depth below `images/` with a `Dockerfile` next to it. It skips hidden dirs. A new family moved in there needs no script change.
- Never runs `*-locally.sh` or `*-local.sh` (e.g. `build-locally.sh`, `build-local.sh`, local-only helpers). Only one build script per directory: a second one stops the run before anything builds, since `.last-upload` and `.build.log` are per directory.
- `-j` (or `PARALLEL`, default 2) sets how many builds run at once. Optional `<path>` args (relative to `images/`, e.g. `corretto`) limit the run to that subtree.
- Before the first build it checks that Docker Hub credentials are stored (credential helper from `credsStore`, or inline `auths` in `~/.docker/config.json`) and exits 1 if not. Presence only, no registry call: an expired token still fails at the push.
- Lists the builds it will run with the reason (never uploaded, changed, older than max age, forced) and asks `continue (Y/n)`. `-y` skips the question; without a terminal `-y` is required.
- On the first failure it starts no new builds, lets running ones finish, then exits 1.
- Each successful build writes `<dir>/.last-upload` (time + sha256 of Dockerfile and build script). A re-run skips a build when that file is younger than `-m` hours (or `MAX_AGE_HOURS`, default 24) and the hash still matches. That is the resume-after-failure path. `-f` ignores the state files and rebuilds everything.
- Per-build output goes to `<dir>/.build.log`. `.last-upload` and `.build.log` are gitignored.
- Editing a Dockerfile or build script changes the hash, so that image rebuilds on the next run.

## Downloads cache

`download.sh <url> <filename>` fetches into `./downloads/` (gitignored) and skips if the file already exists. It is safe for parallel builds: each download goes to its own temp file and is moved into place only when complete, and a per-file lock (`<file>.lock/` dir with the holder's pid, stale locks of dead processes are removed) makes concurrent calls for the same file wait instead of downloading twice. Put the version in `<filename>` so a version bump downloads the new file. Build scripts use this to cache plugin JARs, Kafka tarballs, etc., then copy from `downloads/` into the image build context. Some scripts (`images/sonarqube/build-sonarqube.sh`, `images/kafka/alpine/build-kafka-alpine.sh`) clean up copied artifacts from the build context after the build.

Shared Kafka and Debezium version pins live in `_shared.sh` (`KAFKA_SCALA_VERSION`, `KAFKA_VERSION`, `DEBEZIUM_VERSION`) and are exported for all builds.

## Layout

- Top-level dirs = one image each (e.g. `sonarqube/`, `photon-geocoder/`, `cyberchef/`).
- `images/` — independent image families built in batches by `images/build.sh` (see above), e.g. `corretto/`, `openjdk/`, `kafka/`, `sonarqube/`, `nagios/`. OS variants are subdirs with their own build script (e.g. `images/kafka/alpine/`, `images/kafka/ubuntu/`).
- `_compose/` holds standalone `docker-compose.yml` stacks (n8n, nextcloud, zabbix) — no build, just compose configs.
- `_shared.sh` — sourced helpers + shared version vars.
- `download.sh` — caching downloader.
- `downloads/` — shared download cache (gitignored).

## Versioning convention

Image tag = upstream version, optionally with OS prefix for variants (e.g. `alpine_2.13-4.2.0`, `jdk21`, `25.12.0.117093-community`). `latest` is passed as the extra-tag argument when desired.
