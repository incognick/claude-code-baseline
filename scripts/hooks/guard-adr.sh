#!/usr/bin/env bash
# Claude Code PreToolUse hook for Edit|Write|MultiEdit.
# Enforces ADR-0001 mechanically:
#   1. An ADR whose status is Accepted (or Superseded) may not be edited by the agent.
#   2. The agent may never set an ADR's status to Accepted; only the human does.
# Reads the tool call as JSON on stdin. Exit 2 blocks the call and returns stderr to Claude.
# Language-agnostic: parses JSON with whichever of python3, node, or jq is installed.
set -euo pipefail

input=$(cat)

# json_field PATH -> prints tool_input.file_path, or the concatenated new text of the edit.
json_extract() {
  local what="$1"
  if command -v python3 >/dev/null 2>&1; then
    printf '%s' "$input" | python3 -c '
import json,sys
t=json.load(sys.stdin).get("tool_input",{})
if sys.argv[1]=="file":
    print(t.get("file_path",""))
else:
    parts=[t.get("content",""), t.get("new_string","")]
    parts+=[e.get("new_string","") for e in t.get("edits",[])]
    print("\n".join(parts))' "$what"
  elif command -v node >/dev/null 2>&1; then
    printf '%s' "$input" | node -e '
let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{
const t=(JSON.parse(s).tool_input)||{};
if(process.argv[1]==="file"){console.log(t.file_path||"");}
else{const p=[t.content||"",t.new_string||"",...((t.edits||[]).map(e=>e.new_string||""))];console.log(p.join("\n"));}
});' "$what"
  elif command -v jq >/dev/null 2>&1; then
    if [[ "$what" == "file" ]]; then
      printf '%s' "$input" | jq -r '.tool_input.file_path // ""'
    else
      printf '%s' "$input" | jq -r '[.tool_input.content // "", .tool_input.new_string // ""] + [(.tool_input.edits // [])[] | .new_string // ""] | join("\n")'
    fi
  else
    echo "guard-adr: need python3, node, or jq to parse the hook input" >&2
    exit 2
  fi
}

file=$(json_extract file)

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

new=$(json_extract new)
if printf '%s' "$new" | grep -qE '^\s*-\s*\*\*Status:\*\*\s*Accepted'; then
  echo "BLOCKED: only the human accepts an ADR (ADR-0001). Leave the status as Proposed and ask for acceptance." >&2
  exit 2
fi
exit 0
