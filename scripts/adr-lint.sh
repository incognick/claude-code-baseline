#!/usr/bin/env bash
# Lint the ADR directory. Exit non-zero on any violation.
set -euo pipefail

ADR_DIR="$(cd "$(dirname "$0")/.." && pwd)/docs/adr"
fail=0
err() { echo "adr-lint: $*" >&2; fail=1; }

files=$(ls "$ADR_DIR" | grep -E '^[0-9]{4}-.*\.md$' | grep -v '^0000-' | sort)

expected=1
for f in $files; do
  num=${f:0:4}
  path="$ADR_DIR/$f"

  [[ $((10#$num)) -eq $expected ]] || err "$f: expected number $(printf '%04d' $expected) (gap or duplicate)"
  expected=$((10#$num + 1))

  head -n1 "$path" | grep -qE "^# ADR-$num: .+" || err "$f: first line must be '# ADR-$num: Title'"

  status=$(sed -nE 's/^- \*\*Status:\*\* //p' "$path" | head -n1)
  case "$status" in
    Proposed|Accepted|Rejected) ;;
    "Superseded by ADR-"[0-9][0-9][0-9][0-9]|"Partially superseded by ADR-"[0-9][0-9][0-9][0-9]) ;;
    "") err "$f: missing Status line" ;;
    *)  err "$f: invalid status '$status'" ;;
  esac

  grep -qE '^- \*\*Date:\*\* [0-9]{4}-[0-9]{2}-[0-9]{2}$' "$path" || err "$f: missing or malformed Date"
  grep -qE '^## TL;DR' "$path" || err "$f: missing '## TL;DR' section"
  grep -qE '^## Context' "$path" || err "$f: missing '## Context' section"
  grep -qE '^## Decision' "$path" || err "$f: missing '## Decision' section"
  grep -qE '^## Consequences' "$path" || err "$f: missing '## Consequences' section"

  # Supersession pointers must resolve both ways.
  if [[ "$status" =~ ADR-([0-9]{4})$ ]]; then
    succ=${BASH_REMATCH[1]}
    ls "$ADR_DIR"/"$succ"-*.md >/dev/null 2>&1 || err "$f: superseded by ADR-$succ, which does not exist"
    grep -qE "^- \*\*Superseded by:\*\* ADR-$succ" "$path" || err "$f: Status and 'Superseded by' line disagree"
    succ_file=$(ls "$ADR_DIR"/"$succ"-*.md 2>/dev/null | head -n1 || true)
    [[ -n "$succ_file" ]] && { grep -qE "^- \*\*Supersedes:\*\* .*ADR-$num" "$succ_file" || err "$f: ADR-$succ does not declare 'Supersedes: ADR-$num'"; }
  else
    grep -qE '^- \*\*Superseded by:\*\* —' "$path" || err "$f: status is '$status' but 'Superseded by' is not '—'"
  fi

  # TL;DR length: header to next section, at most 6 non-blank lines.
  tldr_lines=$(awk '/^## TL;DR/{f=1;next} /^## /{f=0} f && NF' "$path" | wc -l | tr -d ' ')
  [[ "$tldr_lines" -le 6 ]] || err "$f: TL;DR is $tldr_lines lines; max 6"
done

# Index in README must match.
tmp=$(mktemp); cp "$ADR_DIR/README.md" "$tmp"
"$(dirname "$0")/adr-index.sh"
if ! diff -q "$tmp" "$ADR_DIR/README.md" >/dev/null; then
  mv "$tmp" "$ADR_DIR/README.md"
  err "README.md index is out of date; run 'task adr:index'"
else
  rm -f "$tmp"
fi

[[ $fail -eq 0 ]] && echo "adr-lint: ok"
exit $fail
