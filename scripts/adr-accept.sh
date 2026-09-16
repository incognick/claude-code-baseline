#!/usr/bin/env bash
# Record the human's decision on a Proposed ADR.
# Usage: scripts/adr-accept.sh NNNN            -> Accepted
#        scripts/adr-accept.sh NNNN reject "reason" -> Rejected
# Run this ONLY after the human has explicitly chosen Accept or Reject in conversation (ADR-0001).
set -euo pipefail

ADR_DIR="$(cd "$(dirname "$0")/.." && pwd)/docs/adr"
NUM="${1:-}"; ACTION="${2:-accept}"; REASON="${3:-}"
[[ "$NUM" =~ ^[0-9]{4}$ ]] || { echo "usage: $0 NNNN [reject \"reason\"]" >&2; exit 1; }

file=$(ls "$ADR_DIR"/"$NUM"-*.md 2>/dev/null | head -n1 || true)
[[ -f "$file" ]] || { echo "ADR-$NUM not found" >&2; exit 1; }

status=$(sed -nE 's/^- \*\*Status:\*\* //p' "$file" | head -n1)
[[ "$status" == "Proposed" ]] || { echo "ADR-$NUM is '$status', not Proposed" >&2; exit 1; }

today=$(date +%F)
case "$ACTION" in
  accept) new="Accepted"; line="- **Accepted:** $today, by the human in conversation" ;;
  reject) [[ -n "$REASON" ]] || { echo "reject needs a one-line reason" >&2; exit 1; }
          new="Rejected"; line="- **Rejected:** $today — $REASON" ;;
  *) echo "action must be accept or reject" >&2; exit 1 ;;
esac

tmp=$(mktemp)
awk -v new="$new" -v line="$line" '
  /^- \*\*Status:\*\* Proposed$/ { print "- **Status:** " new; next }
  /^- \*\*Date:\*\* /            { print; print line; next }
  { print }
' "$file" > "$tmp" && mv "$tmp" "$file"

"$(dirname "$0")/adr-index.sh"
echo "ADR-$NUM: $new"
