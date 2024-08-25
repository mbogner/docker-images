#!/bin/bash
MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MY_DIR/_shared.sh"
URL=$1
TARGET="$DOWNLOADS_DIR/$2"

echo "#############################################################################################################"
echo "# Download:"
echo "# URL=$URL"
echo "# TARGET=$TARGET"
echo "#############################################################################################################"

if [[ ! -d "$DOWNLOADS_DIR" ]]; then
  mkdir "$DOWNLOADS_DIR"
fi

if [[ -f "$TARGET" ]]; then
  echo "skipping download - already exists"
else
  echo "starting download"
  wget "$URL" -O "$TARGET" || exit 1
fi
