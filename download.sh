#!/bin/bash
URL=$1
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
DOWNLOADS_DIR="$SCRIPT_DIR/downloads"
TARGET="$DOWNLOADS_DIR/$2"

if [[ ! -d "$DOWNLOADS_DIR" ]]; then
  mkdir "$DOWNLOADS_DIR"
fi

if [[ -f "$TARGET" ]]; then
  echo "$TARGET already exists"
else
  wget "$URL" -O "$TARGET" || exit 1
fi
