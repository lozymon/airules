#!/usr/bin/env bash
# Validate every ruleshub.json under the workspace.
# Walks rules/, commands/, skills/, workflows/, agents/, mcp-servers/, packs/.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

failed=0
count=0

while IFS= read -r -d '' manifest; do
  count=$((count + 1))
  dir="$(dirname "$manifest")"
  rel="${dir#$ROOT/}"
  if (cd "$dir" && ruleshub validate >/dev/null 2>&1); then
    echo "  ok    $rel"
  else
    echo "  FAIL  $rel"
    (cd "$dir" && ruleshub validate) || true
    failed=$((failed + 1))
  fi
done < <(find rules commands skills workflows agents mcp-servers packs \
            -maxdepth 2 -name ruleshub.json -print0 2>/dev/null)

echo
echo "validated $count assets, $failed failed"
exit $((failed > 0 ? 1 : 0))
