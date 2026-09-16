#!/usr/bin/env bash
# Claude Code PreToolUse hook for Bash.
# Closes the side door: the agent may not write to ADR files from the shell either.
# Allowed: the repository's own adr scripts (task adr:*, scripts/adr-*.sh) and read-only commands.
set -euo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | { python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null \
  || node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>console.log((JSON.parse(s).tool_input||{}).command||""))' 2>/dev/null \
  || jq -r '.tool_input.command // ""' 2>/dev/null; } || true)

# Only care about commands that mention an ADR file or the ADR directory.
printf '%s' "$cmd" | grep -qE 'docs/adr' || exit 0

# The sanctioned tooling is fine.
printf '%s' "$cmd" | grep -qE '(^|[;&|]\s*)(task adr:|scripts/adr-|\./scripts/adr-)' && exit 0

# Anything that looks like a write to the directory is refused.
if printf '%s' "$cmd" | grep -qE '(sed\s+(-[a-zA-Z]*i|--in-place)|perl\s+-[a-zA-Z]*i|>{1,2}\s*[^&]|\btee\b|\bmv\b|\bcp\b|\brm\b|\btruncate\b|python3?\s+-c|node\s+-e|\bawk\b.*>|\bcat\b.*<<)'; then
  echo "BLOCKED: shell writes to docs/adr are not allowed (ADR-0001). Create with 'task adr:new', supersede with 'task adr:supersede'. Only a human accepts, via 'task adr:accept' in their own terminal." >&2
  exit 2
fi
exit 0
