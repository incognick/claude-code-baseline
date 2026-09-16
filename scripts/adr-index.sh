#!/usr/bin/env bash
# Regenerate the index table in docs/adr/README.md between the marker comments.
set -euo pipefail

ADR_DIR="$(cd "$(dirname "$0")/.." && pwd)/docs/adr"
README="$ADR_DIR/README.md"

rows=$(mktemp)
{
  echo "| # | Title | Status |"
  echo "|---|---|---|"
  for f in $(ls "$ADR_DIR" | grep -E '^[0-9]{4}-' | grep -v '^0000-' | sort); do
    num=${f:0:4}
    title=$(sed -nE "1s/^# ADR-$num: //p" "$ADR_DIR/$f")
    status=$(sed -nE 's/^- \*\*Status:\*\* //p' "$ADR_DIR/$f" | head -n1)
    echo "| [$num]($f) | $title | $status |"
  done
} > "$rows"

start=$(grep -n '<!-- adr-index:start -->' "$README" | cut -d: -f1)
end=$(grep -n '<!-- adr-index:end -->' "$README" | cut -d: -f1)
[[ -n "$start" && -n "$end" ]] || { echo "adr-index: markers not found in README.md" >&2; exit 1; }

tmp=$(mktemp)
{
  head -n "$start" "$README"
  cat "$rows"
  tail -n +"$end" "$README"
} > "$tmp"
mv "$tmp" "$README"
rm -f "$rows"
