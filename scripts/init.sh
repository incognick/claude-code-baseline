#!/usr/bin/env bash
# Run once after "Use this template". Strips the template-only files so the
# repository reads as your project, not as claude-code-baseline.
# Idempotent; safe to re-run.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

name="${1:-$(basename "$ROOT")}"

rm -f CONTRIBUTING.md LICENSE

cat > README.md <<README
# $name

<!-- One paragraph: what this is, who it is for. -->

Built with Claude Code. Decisions live in [docs/adr/](docs/adr/);
read [CLAUDE.md](CLAUDE.md) for how to work here.

\`\`\`sh
task --list
\`\`\`
README

# Remove the init task itself from the Taskfile.
tmp=$(mktemp)
awk '
  /^  init:$/ { skip=1; next }
  skip && /^  [a-z]/ { skip=0 }
  !skip { print }
' Taskfile.yml > "$tmp" && mv "$tmp" Taskfile.yml
rm -f scripts/init.sh

echo "initialized '$name': removed CONTRIBUTING.md, LICENSE, scripts/init.sh; rewrote README.md"
echo "next: git add -A && git commit -m 'Initialize from claude-code-baseline'"
