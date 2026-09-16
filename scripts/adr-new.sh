#!/usr/bin/env bash
# Create the next-numbered ADR from the template.
# Usage: scripts/adr-new.sh "Title in the imperative"
set -euo pipefail

ADR_DIR="$(cd "$(dirname "$0")/.." && pwd)/docs/adr"
TITLE="${1:-}"
if [[ -z "$TITLE" ]]; then
  echo "usage: $0 \"Title in the imperative\"" >&2
  exit 1
fi

last=$(ls "$ADR_DIR" | grep -E '^[0-9]{4}-' | grep -v '^0000-' | sort | tail -n1 | cut -c1-4 || true)
next=$(printf '%04d' $((10#${last:-0} + 1)))

slug=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
file="$ADR_DIR/$next-$slug.md"

sed -e "s/^# ADR-0000: Title in the imperative/# ADR-$next: $TITLE/" \
    -e "s/YYYY-MM-DD/$(date +%F)/" \
    "$ADR_DIR/0000-template.md" > "$file"

"$(dirname "$0")/adr-index.sh"
echo "$file"
