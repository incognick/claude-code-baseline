#!/usr/bin/env bash
# Human-only: move an ADR from Proposed to Accepted (or Rejected).
# Usage: scripts/adr-accept.sh NNNN [reject "reason"]
# Refuses to run without an interactive terminal, so an agent's shell cannot call it.
set -euo pipefail

if ! ( : </dev/tty ) 2>/dev/null; then
  echo "adr-accept: refusing — no interactive terminal. Only a human accepts an ADR (ADR-0001). Run this yourself in a terminal." >&2
  exit 2
fi

ADR_DIR="$(cd "$(dirname "$0")/.." && pwd)/docs/adr"
NUM="${1:-}"; ACTION="${2:-accept}"; REASON="${3:-}"
[[ "$NUM" =~ ^[0-9]{4}$ ]] || { echo "usage: $0 NNNN [reject \"reason\"]" >&2; exit 1; }

file=$(ls "$ADR_DIR"/"$NUM"-*.md 2>/dev/null | head -n1 || true)
[[ -f "$file" ]] || { echo "ADR-$NUM not found" >&2; exit 1; }

status=$(sed -nE 's/^- \*\*Status:\*\* //p' "$file" | head -n1)
[[ "$status" == "Proposed" ]] || { echo "ADR-$NUM is '$status', not Proposed" >&2; exit 1; }

case "$ACTION" in
  accept) new="Accepted" ;;
  reject) [[ -n "$REASON" ]] || { echo "reject needs a one-line reason" >&2; exit 1; }
          new="Rejected — $REASON" ;;
  *) echo "action must be accept or reject" >&2; exit 1 ;;
esac

title=$(sed -nE "1s/^# ADR-$NUM: //p" "$file")
printf 'ADR-%s: %s\n  %s -> %s\nConfirm [y/N] ' "$NUM" "$title" "$status" "$new"
read -r ans </dev/tty
[[ "$ans" == "y" || "$ans" == "Y" ]] || { echo "aborted"; exit 1; }

tmp=$(mktemp)
sed -E "s/^- \*\*Status:\*\* Proposed$/- **Status:** $new/" "$file" > "$tmp" && mv "$tmp" "$file"
"$(dirname "$0")/adr-index.sh"
echo "ADR-$NUM: $new"
