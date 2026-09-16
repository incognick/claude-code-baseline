# CLAUDE.md — Orientation for Claude Code sessions

This file tells you **what exists and how to work on it**. It
deliberately does **not** explain *why* anything is the way it is.
The *why* lives in `docs/adr/`.

## Where the decisions live

`docs/adr/` is the decision log. Read `docs/adr/README.md` first — it
carries the process and an index with a one-line summary of every
decision. Before changing anything architectural, check whether an
ADR already covers it.

**The ADR process, in short (ADR-0001):**

- Claude **proposes** ADRs (`task adr:new -- "Title"`). Only the human
  **accepts** them, by editing the status line. Silence is not
  acceptance.
- Accepted ADRs are **immutable**. Change happens by writing a new ADR
  that supersedes the old one, fully or partially. The old file's only
  edit is its `Superseded by` pointer, applied by
  `task adr:supersede -- OLD NEW`. A hook blocks any other edit.
- ADRs never track implementation status. Once accepted, Claude opens
  **issues** for the work the ADR implies.
- Every ADR opens with a caveman TL;DR. Keep it that way.
- Ideas that are not yet decisions go in `docs/ideas.md`.

## What this project is

<!-- Fill this in. Two or three sentences: what it is, who it is for,
where it runs. Delete this comment. -->

_Not yet described. The first accepted ADR should be the stack; the
second should be the hosting target._

## The working loop (ADR-0003)

This is not optional and not a style preference. It is the process.

1. **An ADR is accepted before any implementation starts.** Not
   proposed — accepted, explicitly, by the human. If something looks
   urgent enough to skip that, say so out loud and let the human
   decide. Do not decide it yourself. Almost nothing is urgent.
2. **Accepted ADR, then issues, then code.** Issues are the work
   tracker. ADRs never track status.
3. **Every code change goes through a subagent.** Every one, however
   small. The main thread does not write implementation code; it
   reviews the diff as an independent reader.
4. **Subagents work in worktrees and open PRs.** The main thread
   reviews, merges, and resolves conflicts. Max five in parallel.
5. **No long-lived agents.** Every agent is new.
6. **Every PR links its issue and its ADR.** The PR template asks.

## How to work here

- **Follow the ADRs.** If the right move contradicts an accepted ADR,
  do not quietly deviate — propose a superseding ADR.
- **Build the current scope only.** Do not build ahead.
- **Substitutions need a real reason, not a preference.** "I have more
  context now and the original choice doesn't fit" is a reason. "I'd
  rather use X" is not.
- **Propose, don't ask, for things you can verify yourself.** Ask when
  it changes product direction.
- **Honest status (ADR-0002).** Present tense means shipped and
  verified. "What is built" below changes in the same PR as the code.
- `task` is the entrypoint for everything. `task --list` shows what
  exists. Add project tasks there, never as loose scripts.

## Enforcement

- `.claude/settings.json` registers `scripts/hooks/guard-adr.sh` as a
  `PreToolUse` hook on `Edit|Write|MultiEdit`. It blocks agent edits
  to any accepted or superseded ADR, and blocks the agent from writing
  `Status: Accepted` anywhere under `docs/adr/`. If the hook blocks
  you, it is right; do what its message says.
- `task adr:lint` runs in CI (`.github/workflows/ci.yml`). It fails on
  numbering gaps, invalid statuses, missing sections, dangling
  supersession pointers, and a stale index.

## Traps

<!-- Each entry here should have cost real time before. Add them as
they happen; delete this comment. -->

- (none yet)

## What is built

Nothing user-facing. This repository is the baseline: the ADR process,
its tooling, the hook, and CI for the lint. The stack, the hosting
target, and the product are all undecided until their ADRs exist and
are accepted.

## What is next

1. Human accepts or rejects ADR-0001, ADR-0002, ADR-0003.
2. Claude proposes the stack ADR and the hosting ADR.
3. Once accepted, Claude opens the first issues.
