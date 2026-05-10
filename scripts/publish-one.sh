#!/usr/bin/env bash
# Publish a single asset by path.
# Usage: bash scripts/publish-one.sh rules/typescript-strict
# Requires: RULESHUB_TOKEN env var

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <asset-path>" >&2
  echo "example: $0 rules/typescript-strict" >&2
  exit 64
fi

if [[ -z "${RULESHUB_TOKEN:-}" ]]; then
  echo "error: RULESHUB_TOKEN is not set" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
target="$ROOT/$1"

if [[ ! -f "$target/ruleshub.json" ]]; then
  echo "error: $target/ruleshub.json not found" >&2
  exit 1
fi

cd "$target"
ruleshub validate
ruleshub publish
