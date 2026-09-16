#!/usr/bin/env bash
# Claude Code PreToolUse hook for Edit|Write|MultiEdit.
# Enforces ADR-0001 mechanically:
#   1. An ADR whose status is Accepted (or Superseded) may not be edited by the agent.
#   2. The agent may never set an ADR's status to Accepted; only the human does.
# Reads the tool call as JSON on stdin. Exit 2 blocks the call and returns stderr to Claude.
set -euo pipefail

input=$(cat)
file=$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)

case "$file" in
  */docs/adr/[0-9][0-9][0-9][0-9]-*.md) ;;
  *) exit 0 ;;
esac

if [[ -f "$file" ]]; then
  status=$(sed -nE 's/^- \*\*Status:\*\* //p' "$file" | head -n1)
  case "$status" in
    Accepted|"Superseded by"*|"Partially superseded by"*)
      echo "BLOCKED: $(basename "$file") is $status and therefore immutable (ADR-0001). Write a new ADR that supersedes it, get it accepted, then run 'task adr:supersede -- OLD NEW'." >&2
      exit 2 ;;
  esac
fi

# Any attempt to write "Status: Accepted" into an ADR is refused.
new=$(printf '%s' "$input" | python3 -c '
import json,sys
t=json.load(sys.stdin).get("tool_input",{})
parts=[t.get("content",""), t.get("new_string","")]
parts+=[e.get("new_string","") for e in t.get("edits",[])]
print("\n".join(parts))' 2>/dev/null || true)
if printf '%s' "$new" | grep -qE '^\s*-\s*\*\*Status:\*\*\s*Accepted'; then
  echo "BLOCKED: only the human accepts an ADR (ADR-0001). Leave the status as Proposed and ask for acceptance." >&2
  exit 2
fi
exit 0
