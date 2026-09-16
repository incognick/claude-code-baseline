# ADR-0001: Decisions are recorded as ADRs, and accepted ADRs are immutable

- **Status:** Proposed
- **Date:** 2026-09-16
- **Supersedes:** —
- **Superseded by:** —

## TL;DR

Every architectural decision gets one ADR in `docs/adr/`. Claude
proposes. Human accepts. Accepted ADR never edited — superseded by new
ADR instead. Old ADR gets one pointer line, nothing else. ADRs record
decisions, never status. Hook enforces, not goodwill.

## Context

Projects built with an AI agent lose their "why" faster than projects
built by hand. The agent has no memory between sessions, so every
session re-derives decisions from the code, and re-deriving is where
drift starts: a choice made for a good reason gets quietly reversed
because the reason was never written down. The next session reverses
it back. Code churns, nothing improves.

The fix that has worked across several projects is a decision log
that the agent must read before changing anything architectural, and
must not be able to edit after the fact. Three failure modes shaped
the rules below:

1. The agent "cleaned up" an old ADR to match the code it had just
   changed, erasing the record of what had been decided and why.
2. The agent marked its own proposal as accepted and started
   implementing. The human had not read it.
3. ADRs accumulated "Status: done / in progress / TODO" lines and
   became a stale task tracker nobody trusted.

## Decision

- One decision per ADR, in `docs/adr/NNNN-slug.md`, numbered
  sequentially from `0001`, created from `0000-template.md` via
  `task adr:new -- "Title"`.
- Every ADR opens with a caveman **TL;DR**: three to five lines, no
  articles, no hedging. The rest is normal prose.
- **Claude proposes; only the human accepts.** Claude writes ADRs with
  `Status: Proposed`. The human moves an ADR to `Accepted` with
  `task adr:accept -- NNNN`, which refuses to run without an
  interactive terminal, or by editing the status line themselves.
  Silence is not acceptance.
- **Accepted ADRs are immutable.** Not for typos, not for "we learned
  more." The file is frozen.
- **Change happens by supersession.** A new ADR states
  `Supersedes: ADR-NNNN (fully | partially)`. The old ADR receives
  exactly one edit — its `Superseded by:` line — applied by
  `task adr:supersede -- NNNN MMMM`, never by hand and never by
  Claude.
- **ADRs never track status.** No "done", "shipped", "TODO". Work is
  tracked in issues; what is currently built is described in
  `CLAUDE.md` and the README.
- **Ideas are not ADRs.** Things we might build go in `docs/ideas.md`
  with no ceremony. An idea becomes an ADR when we are deciding to do
  it, not when we are considering it.
- **Enforcement is mechanical.** Two Claude Code `PreToolUse` hooks
  (`scripts/hooks/guard-adr.sh` on Edit/Write,
  `scripts/hooks/guard-adr-bash.sh` on Bash) reject any agent write
  that touches an accepted ADR or would set an ADR's status to
  `Accepted`, whether through the editing tools or the shell. The
  sanctioned scripts are the only path. `task adr:lint` runs in CI and
  fails on numbering gaps, missing TL;DR, invalid statuses, dangling
  supersession pointers, and an out-of-date index.

## Consequences

- Slower start on any architectural change: write the ADR, wait for
  acceptance, then build. This is the point. The cost has paid for
  itself every time it was skipped.
- The human is a hard dependency. Nothing architectural ships while
  they are away. Acceptable for a solo or small-team project; a larger
  team would name more than one acceptor in a superseding ADR.
- Typos in accepted ADRs live forever. Read before accepting.
- Rejected and superseded ADRs are kept. Knowing what was turned down
  is as useful as knowing what was picked.
- The hooks only bind Claude Code. A human with a text editor can
  still edit anything; the lint in CI and review are the backstop.
  The Bash guard is pattern-based and can be fooled by a determined
  agent; it raises the bar, it is not a sandbox.

## Alternatives considered

- **Decisions in `CLAUDE.md`.** Tried. It grows until nobody reads it,
  and the agent edits it freely, so the record is not stable.
- **Decisions in commit messages.** Not discoverable; the agent does
  not read history before acting.
- **Editable ADRs with git history as the record.** The agent does not
  read git history either, and "the ADR says X" must mean X without a
  `git log` to check.
- **No human gate on acceptance.** Tried by accident. See failure mode
  2.
