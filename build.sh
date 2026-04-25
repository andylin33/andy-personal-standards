#!/usr/bin/env bash
# Build andy-personal-standards.plugin from this source dir.
# Usage: ./build.sh
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT="${1:-/tmp/andy-personal-standards.plugin}"
rm -f "$OUT"
cd "$HERE"
zip -r "$OUT" . \
  -x "*.DS_Store" \
  -x ".git/*" \
  -x "*.plugin" \
  -x "build.sh"
echo ""
echo "Built: $OUT"
