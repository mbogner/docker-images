#!/usr/bin/env bash
#
# Builds and pushes all images below images/ with a configurable number of builds
# running in parallel. Every directory at any depth that contains a Dockerfile and
# a build-*.sh script is one build (e.g. corretto/jdk21/build-corretto-jdk21.sh).
# Scripts named *-locally.sh or *-local.sh (e.g. build-locally.sh, build-local.sh) are local helpers and never run.
# Each directory may hold only one build script, because state and log are per directory.
# Builds run in any order, except those matched by BUILD_FIRST (below), which run first
# in the given order - for images built on top of other images from images/.
#
# Every successful build writes a small state file (.last-upload, gitignored) into
# its directory. A later run skips a build when its state file is younger than the
# max age and the Dockerfile + build script did not change since that upload. This
# lets you re-run the script after a failure without rebuilding and re-uploading
# the images that already went through.
#
# On the first failing build, no new builds are started. Builds that are already
# running are allowed to finish (so their state is recorded), then the script exits 1.
#
# Usage: ./build.sh [-j <parallel>] [-m <max-age-hours>] [-f] [-y] [<path>...]
#   -j      number of builds to run in parallel (default: $PARALLEL or 2)
#   -m      max age in hours of a successful upload to still count as done (default: $MAX_AGE_HOURS or 24)
#   -f      force: ignore state files and rebuild everything
#   -y      yes: don't ask "continue (Y/n)" before building (required when not run in a terminal)
#   <path>  only build below these paths, relative to images/ (e.g. corretto, corretto/jdk21)
#
# Per-build output goes to <dir>/.build.log (gitignored).
#
# Before the first build the script checks that Docker Hub credentials are stored
# (docker login), because every build pushes and would otherwise only fail at the end.
# It only checks that credentials exist: an expired token still fails at the push.

set -u

# Builds that must run before the rest, in exactly this order. Each entry is a glob pattern on
# the build directory relative to images/ (e.g. "corretto/jre25-alpine", "openjdk/*") and forms
# one stage: every build of a stage must succeed before the next stage starts, the builds within
# a stage run in parallel. A build matched by several patterns belongs to the first one.
# Builds matched by no pattern run in the last stage.
BUILD_FIRST=(
  "corretto/*"   # base of kafka/alpine (jre25-alpine) and docker-dind-alpine-healthcheck (jdk21/25-alpine)
  "openjdk/*"    # base of kafka/ubuntu (mbopm/openjdk:jre25-ubuntu)
)

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# no set -e on purpose: failed builds (wait), polling (kill -0) and plain tests return
# non-zero by design. Commands that must not fail are checked explicitly instead.
cd "${DIR}" || exit 1

PARALLEL="${PARALLEL:-2}"
MAX_AGE_HOURS="${MAX_AGE_HOURS:-24}"
FORCE=0
ASSUME_YES=0
STATE_FILE_NAME=".last-upload"
LOG_FILE_NAME=".build.log"
POLL_SECONDS=2

usage() {
  sed -n '20,25p' "$DIR/$(basename "${BASH_SOURCE[0]}")" | sed 's/^# \{0,1\}//'
}

while getopts ":j:m:fyh" opt; do
  case "$opt" in
    j) PARALLEL="$OPTARG" ;;
    m) MAX_AGE_HOURS="$OPTARG" ;;
    f) FORCE=1 ;;
    y) ASSUME_YES=1 ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

if ! [[ "$PARALLEL" =~ ^[1-9][0-9]*$ ]]; then
  echo "error: -j must be a positive integer (got '$PARALLEL')" >&2
  exit 1
fi
if ! [[ "$MAX_AGE_HOURS" =~ ^[0-9]+$ ]]; then
  echo "error: -m must be a non-negative integer (got '$MAX_AGE_HOURS')" >&2
  exit 1
fi

if command -v sha256sum >/dev/null 2>&1; then
  hash_cmd() { sha256sum "$@"; }
else
  hash_cmd() { shasum -a 256 "$@"; }
fi

# Hash of everything that defines the build: Dockerfile + build script.
inputs_hash() {
  local build_dir=$1 script=$2
  cat "$build_dir/Dockerfile" "$build_dir/$script" | hash_cmd | awk '{print $1}'
}

# Returns 0 and prints why if the build in $1 must run; returns 1 if it can be skipped.
build_reason() {
  local build_dir=$1 script=$2
  local state="$build_dir/$STATE_FILE_NAME"
  [[ $FORCE -eq 0 ]] || { echo "forced (-f)"; return 0; }
  [[ -f "$state" ]] || { echo "never uploaded"; return 0; }

  local last_epoch last_hash now max_age
  last_epoch=$(sed -n 's/^LAST_UPLOAD_EPOCH=//p' "$state")
  last_hash=$(sed -n 's/^INPUTS_SHA256=//p' "$state")
  [[ "$last_epoch" =~ ^[0-9]+$ ]] || { echo "state file unreadable"; return 0; }

  now=$(date +%s)
  max_age=$((MAX_AGE_HOURS * 3600))
  (( now - last_epoch <= max_age )) || { echo "last upload older than ${MAX_AGE_HOURS}h"; return 0; }
  [[ "$last_hash" == "$(inputs_hash "$build_dir" "$script")" ]] || { echo "Dockerfile or build script changed"; return 0; }
  return 1
}

write_state() {
  local build_dir=$1 script=$2
  local tmp="$build_dir/$STATE_FILE_NAME.tmp"
  {
    echo "# written by build.sh - last successful build + push"
    echo "LAST_UPLOAD=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "LAST_UPLOAD_EPOCH=$(date +%s)"
    echo "BUILD_SCRIPT=$script"
    echo "INPUTS_SHA256=$(inputs_hash "$build_dir" "$script")"
  } >"$tmp" && mv "$tmp" "$build_dir/$STATE_FILE_NAME"
}

# ---------------------------------------------------------------------------------
# collect builds
# ---------------------------------------------------------------------------------
SEARCH_PATHS=()
for p in "$@"; do
  while [[ "$p" == */ && "$p" != "/" ]]; do p="${p%/}"; done
  SEARCH_PATHS+=("$p")
done
[[ ${#SEARCH_PATHS[@]} -eq 0 ]] && SEARCH_PATHS=(.)
for p in "${SEARCH_PATHS[@]}"; do
  if [[ ! -d "$p" ]]; then
    echo "error: '$p' is not a directory below $DIR" >&2
    exit 1
  fi
done

# Index of the first BUILD_FIRST pattern matching build dir $1, or the number of patterns
# (= last stage) if none matches.
build_stage() {
  local k
  [[ ${#BUILD_FIRST[@]} -gt 0 ]] || { echo 0; return; }
  for k in "${!BUILD_FIRST[@]}"; do
    # shellcheck disable=SC2053 # unquoted on purpose: the pattern is a glob
    [[ "$1" == ${BUILD_FIRST[$k]} ]] && { echo "$k"; return; }
  done
  echo "${#BUILD_FIRST[@]}"
}

stage_name() {
  if [[ $1 -lt ${#BUILD_FIRST[@]} ]]; then
    echo "stage $(($1 + 1)): ${BUILD_FIRST[$1]}"
  else
    echo "stage $(($1 + 1)): everything else"
  fi
}

# All found builds; ALL_REASONS is empty for builds that are up to date.
ALL_DIRS=()
ALL_SCRIPTS=()
ALL_REASONS=()
ALL_STAGES=()
SEEN_DIRS=$'\n'
# find all build-*.sh at any depth (skipping hidden dirs and *-locally.sh / *-local.sh), sorted for a stable order
while IFS= read -r s; do
  d="$(dirname "$s")"
  d="${d#./}"
  script="$(basename "$s")"
  [[ -f "$d/Dockerfile" ]] || { echo "warn  $d/$script has no Dockerfile next to it - ignored" >&2; continue; }
  if [[ "$SEEN_DIRS" == *$'\n'"$d"$'\n'* ]]; then
    echo "error: $d has more than one build-*.sh - .last-upload and .build.log would collide." >&2
    echo "       keep one build script per directory (local helpers must be named *-locally.sh or *-local.sh)" >&2
    exit 1
  fi
  SEEN_DIRS+="$d"$'\n'
  reason=$(build_reason "$d" "$script") || reason=""
  ALL_DIRS+=("$d")
  ALL_SCRIPTS+=("$script")
  ALL_REASONS+=("$reason")
  ALL_STAGES+=("$(build_stage "$d")")
done < <(find "${SEARCH_PATHS[@]}" -mindepth 1 -name '.*' -prune -o -type f -name 'build-*.sh' ! -name '*-locally.sh' ! -name '*-local.sh' -print | sort -u)

# Queue the builds by stage (keeping the sorted order within a stage) and print the skipped
# ones in the same order.
QUEUE_DIRS=()
QUEUE_SCRIPTS=()
QUEUE_REASONS=()
QUEUE_STAGES=()
for ((stage = 0; stage <= ${#BUILD_FIRST[@]}; stage++)); do
  for i in "${!ALL_DIRS[@]}"; do
    [[ ${ALL_STAGES[$i]} -eq $stage ]] || continue
    d="${ALL_DIRS[$i]}"
    if [[ -z "${ALL_REASONS[$i]}" ]]; then
      echo "skip  $d/${ALL_SCRIPTS[$i]} (uploaded $(sed -n 's/^LAST_UPLOAD=//p' "$d/$STATE_FILE_NAME"))"
      continue
    fi
    QUEUE_DIRS+=("$d")
    QUEUE_SCRIPTS+=("${ALL_SCRIPTS[$i]}")
    QUEUE_REASONS+=("${ALL_REASONS[$i]}")
    QUEUE_STAGES+=("$stage")
  done
done

TOTAL=${#QUEUE_DIRS[@]}
if [[ $TOTAL -eq 0 ]]; then
  echo "nothing to build - all images up to date (use -f to force)"
  exit 0
fi

# Returns 0 if Docker Hub credentials are stored, without calling the registry.
# With a credential store (e.g. Docker Desktop: "credsStore": "desktop") the helper
# lists the registries it has credentials for; without one they sit inline in config.json.
DOCKERHUB_KEY="https://index.docker.io/v1/"
has_docker_login() {
  local cfg="${DOCKER_CONFIG:-$HOME/.docker}/config.json" store
  [[ -f "$cfg" ]] || return 1
  store=$(sed -n 's/.*"credsStore"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$cfg" | head -n 1)
  if [[ -n "$store" ]]; then
    command -v "docker-credential-$store" >/dev/null 2>&1 || return 1
    "docker-credential-$store" list 2>/dev/null | grep -qF "\"$DOCKERHUB_KEY\""
  else
    grep -A2 -F "\"$DOCKERHUB_KEY\"" "$cfg" | grep -q '"auth"[[:space:]]*:[[:space:]]*"[^"]'
  fi
}

if ! has_docker_login; then
  echo "error: not logged in to Docker Hub - every build pushes, so run 'docker login' first" >&2
  exit 1
fi

echo
echo "to build and push ($TOTAL, $PARALLEL in parallel, each stage waits for the one before):"
for i in "${!QUEUE_DIRS[@]}"; do
  if [[ $i -eq 0 || ${QUEUE_STAGES[$i]} -ne ${QUEUE_STAGES[$((i - 1))]} ]]; then
    echo "  $(stage_name "${QUEUE_STAGES[$i]}")"
  fi
  echo "    ${QUEUE_DIRS[$i]}/${QUEUE_SCRIPTS[$i]} (${QUEUE_REASONS[$i]})"
done

if [[ $ASSUME_YES -eq 0 ]]; then
  if [[ ! -t 0 ]]; then
    echo "error: not running in a terminal, so nobody can confirm - pass -y to build without asking" >&2
    exit 1
  fi
  # read fails on end of input (Ctrl-D): treat that as "no", only Enter means yes
  if ! read -r -p "continue (Y/n) " answer; then
    echo
    echo "aborted - nothing was built"
    exit 1
  fi
  case "$answer" in
    ""|[yY]|[yY][eE][sS]) ;;
    *) echo "aborted - nothing was built"; exit 0 ;;
  esac
fi

echo "building $TOTAL image(s), $PARALLEL in parallel"

# ---------------------------------------------------------------------------------
# run builds (bash 3.2 compatible: no wait -n, no associative arrays)
# ---------------------------------------------------------------------------------
RUN_PIDS=()
RUN_IDX=()
NEXT=0
DONE=0
FAILED=()
RUNNING_STAGE=-1

on_interrupt() {
  echo
  echo "interrupted - killing running builds: ${RUN_PIDS[*]:-none}"
  for p in "${RUN_PIDS[@]:-}"; do
    [[ -n "$p" ]] && kill "$p" 2>/dev/null
  done
  echo "leftover buildx builders can be removed with: docker buildx rm <builder-name>"
  exit 130
}
trap on_interrupt INT TERM

start_build() {
  local i=$1
  local d="${QUEUE_DIRS[$i]}" s="${QUEUE_SCRIPTS[$i]}"
  echo "start $d/$s (log: $d/$LOG_FILE_NAME)"
  bash "$d/$s" >"$d/$LOG_FILE_NAME" 2>&1 &
  RUN_PIDS+=("$!")
  RUN_IDX+=("$i")
}

while :; do
  # start new builds while there is capacity and nothing failed yet. A build of the next
  # stage only starts once every build of the current stage finished (queue is sorted by stage).
  while [[ ${#FAILED[@]} -eq 0 && $NEXT -lt $TOTAL && ${#RUN_PIDS[@]} -lt $PARALLEL ]]; do
    if [[ ${QUEUE_STAGES[$NEXT]} -ne $RUNNING_STAGE ]]; then
      [[ ${#RUN_PIDS[@]} -eq 0 ]] || break
      RUNNING_STAGE=${QUEUE_STAGES[$NEXT]}
      echo "----- $(stage_name "$RUNNING_STAGE")"
    fi
    start_build "$NEXT"
    NEXT=$((NEXT + 1))
  done

  [[ ${#RUN_PIDS[@]} -eq 0 ]] && break

  sleep "$POLL_SECONDS"

  # reap finished builds
  NEW_PIDS=()
  NEW_IDX=()
  for k in "${!RUN_PIDS[@]}"; do
    pid="${RUN_PIDS[$k]}"
    i="${RUN_IDX[$k]}"
    if kill -0 "$pid" 2>/dev/null; then
      NEW_PIDS+=("$pid")
      NEW_IDX+=("$i")
      continue
    fi
    wait "$pid"
    rc=$?
    d="${QUEUE_DIRS[$i]}"
    s="${QUEUE_SCRIPTS[$i]}"
    DONE=$((DONE + 1))
    if [[ $rc -eq 0 ]]; then
      echo "ok    $d/$s ($DONE/$TOTAL)"
      write_state "$d" "$s" || echo "warn  $d/$STATE_FILE_NAME could not be written - the next run builds and pushes this image again" >&2
    else
      FAILED+=("$d/$s")
      echo "FAIL  $d/$s (exit $rc) - last log lines:"
      tail -n 20 "$d/$LOG_FILE_NAME" | sed 's/^/      | /'
      [[ ${#NEW_PIDS[@]} -gt 0 || $NEXT -lt $TOTAL ]] && echo "      no new builds will be started, waiting for running ones..."
    fi
  done
  RUN_PIDS=("${NEW_PIDS[@]+"${NEW_PIDS[@]}"}")
  RUN_IDX=("${NEW_IDX[@]+"${NEW_IDX[@]}"}")
done

if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo "failed: ${FAILED[*]}"
  echo "fix the problem and re-run - successful uploads are skipped"
  exit 1
fi

echo "all $TOTAL build(s) done"
