#!/usr/bin/env bash
# Apply the one permitted edit to an accepted ADR: its "Superseded by" pointer.
# Usage: scripts/adr-supersede.sh OLD NEW [partially]
#   OLD, NEW are four-digit ADR numbers. NEW must exist and be Accepted.
set -euo pipefail

ADR_DIR="$(cd "$(dirname "$0")/.." && pwd)/docs/adr"
OLD="${1:-}"; NEW="${2:-}"; MODE="${3:-fully}"
if [[ ! "$OLD" =~ ^[0-9]{4}$ || ! "$NEW" =~ ^[0-9]{4}$ ]]; then
  echo "usage: $0 OLD NEW [partially]" >&2
  exit 1
fi

old_file=$(ls "$ADR_DIR"/"$OLD"-*.md 2>/dev/null | head -n1 || true)
new_file=$(ls "$ADR_DIR"/"$NEW"-*.md 2>/dev/null | head -n1 || true)
[[ -f "$old_file" ]] || { echo "ADR-$OLD not found" >&2; exit 1; }
[[ -f "$new_file" ]] || { echo "ADR-$NEW not found" >&2; exit 1; }

grep -qE '^- \*\*Status:\*\* Accepted' "$new_file" \
  || { echo "ADR-$NEW is not Accepted; accept it first" >&2; exit 1; }
grep -qE "^- \*\*Supersedes:\*\* .*ADR-$OLD" "$new_file" \
  || { echo "ADR-$NEW does not declare 'Supersedes: ADR-$OLD'" >&2; exit 1; }

case "$MODE" in
  fully)     status="Superseded by ADR-$NEW" ;;
  partially) status="Partially superseded by ADR-$NEW" ;;
  *) echo "mode must be 'fully' or 'partially'" >&2; exit 1 ;;
esac

# Two lines change and nothing else: Status and Superseded by.
tmp=$(mktemp)
awk -v status="$status" -v new="$NEW" '
  /^- \*\*Status:\*\* /        { print "- **Status:** " status; next }
  /^- \*\*Superseded by:\*\* / { print "- **Superseded by:** ADR-" new; next }
  { print }
' "$old_file" > "$tmp"
mv "$tmp" "$old_file"

"$(dirname "$0")/adr-index.sh"
echo "ADR-$OLD: $status"
