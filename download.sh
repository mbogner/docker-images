#!/usr/bin/env bash
#
# Usage: download.sh <url> <filename>
#
# Downloads <url> into downloads/<filename> once; later calls reuse the cached file.
#
# Safe for parallel builds (e.g. images/build.sh building several Kafka images):
# - Every download writes to its own temp file and only moves it to <filename> once it
#   completed. A file under its final name is therefore always complete, and a failed or
#   interrupted download never leaves a half file behind that later runs would reuse.
# - A lock per file (a lock directory, because mkdir is atomic and macOS has no flock)
#   makes concurrent calls for the same file wait for the first one instead of
#   downloading it again. A lock left behind by a killed process is detected and removed.
#
# DOWNLOAD_LOCK_TIMEOUT (seconds, default 1800) limits how long a call waits for another
# download of the same file.

set -u

MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
source "$MY_DIR/_shared.sh" || exit 1

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <url> <filename>" >&2
  exit 1
fi
URL=$1
TARGET="$DOWNLOADS_DIR/$2"
LOCK="$TARGET.lock"
PART="$TARGET.part.$$"
LOCK_TIMEOUT="${DOWNLOAD_LOCK_TIMEOUT:-1800}"

echo "#############################################################################################################"
echo "# Download:"
echo "# URL=$URL"
echo "# TARGET=$TARGET"
echo "#############################################################################################################"

mkdir -p "$DOWNLOADS_DIR" || exit 1

if [[ -f "$TARGET" ]]; then
  echo "skipping download - already exists"
  exit 0
fi

# Acquire the lock for this file. Only one process can create the lock directory.
waited=0
until mkdir "$LOCK" 2>/dev/null; do
  holder=$(cat "$LOCK/pid" 2>/dev/null || true)
  if [[ -n "$holder" ]] && ! kill -0 "$holder" 2>/dev/null; then
    # the process holding the lock is gone (killed build): remove its lock, unless
    # another process replaced it in the meantime
    if [[ "$(cat "$LOCK/pid" 2>/dev/null || true)" == "$holder" ]]; then
      echo "removing stale lock of process $holder"
      rm -rf "$LOCK"
    fi
    continue
  fi
  if [[ $waited -eq 0 ]]; then
    echo "waiting for another download of $2 to finish (pid ${holder:-?})"
  fi
  if [[ $waited -ge $LOCK_TIMEOUT ]]; then
    echo "error: waited ${LOCK_TIMEOUT}s for the lock $LOCK - remove it if no download is running" >&2
    exit 1
  fi
  sleep 2
  waited=$((waited + 2))
done
echo $$ >"$LOCK/pid"
trap 'rm -f "$PART"; rm -rf "$LOCK"' EXIT
trap 'exit 130' INT TERM

# another process may have finished the download while this one waited for the lock
if [[ -f "$TARGET" ]]; then
  echo "skipping download - finished by another build"
  exit 0
fi

echo "starting download"
if ! wget "$URL" -O "$PART"; then
  echo "error: download of $URL failed" >&2
  exit 1
fi
mv "$PART" "$TARGET" || exit 1
echo "download complete"
