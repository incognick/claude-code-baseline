# ADR-0001: Decisions are recorded as ADRs, and accepted ADRs are immutable

- **Status:** Proposed
- **Date:** 2026-09-16
- **Supersedes:** —
- **Superseded by:** —

## TL;DR

Every architectural decision gets one ADR in `docs/adr/`. Agent
proposes, explains in plain language, asks. Human accepts in
conversation. Accepted ADR never edited — superseded by new ADR
instead. ADRs record decisions, never status. Hooks enforce, not
goodwill.

## Context

Projects built with an AI agent lose their "why" faster than projects
built by hand. The agent has no memory between sessions, so every
session re-derives decisions from the code, and re-deriving is where
drift starts: a choice made for a good reason gets quietly reversed
because the reason was never written down. The next session reverses
it back. Code churns, nothing improves.

The human directing the project may not be technical and may never
read the code. The decision log is therefore also the one place they
can see, in plain language, what was decided on their behalf and why.

Three failure modes shaped the rules below:

1. The agent "cleaned up" an old ADR to match the code it had just
   changed, erasing the record of what had been decided and why.
2. The agent marked its own proposal as accepted and started
   implementing. The human had not read it.
3. ADRs accumulated "Status: done / in progress / TODO" lines and
   became a stale task tracker nobody trusted.

## Decision

- One decision per ADR, in `docs/adr/NNNN-slug.md`, numbered
  sequentially from `0001`, created by the agent with
  `task adr:new -- "Title"` from `0000-template.md`.
- Every ADR opens with a **TL;DR**: three to five lines, blunt, no
  hedging. The rest is normal prose.
- **The agent proposes; only the human accepts.** The agent writes the
  ADR with `Status: Proposed`, then presents it to the human in plain
  language — what is being decided, why, what it costs, what the
  alternatives were — and asks a structured question with the options
  **Accept**, **Reject**, and **Change something**. The agent never
  infers acceptance from silence, from a vague "ok", or from the human
  asking to proceed with unrelated work.
- On an explicit **Accept**, the agent runs `task adr:accept -- NNNN`, which sets the status and records the acceptance date. On
  **Reject**, `task adr:accept -- NNNN reject "reason"`. On
  **Change**, the agent edits the still-Proposed ADR and asks again.
- **Accepted ADRs are immutable.** Not for typos, not for "we learned
  more." The file is frozen.
- **Change happens by supersession.** A new ADR states
  `Supersedes: ADR-NNNN (fully | partially)`. Once it is accepted, the
  agent runs `task adr:supersede -- NNNN MMMM`, which applies the
  one permitted edit to the old file: its `Superseded by` pointer.
- **ADRs never track status.** No "done", "shipped", "TODO". Work is
  tracked in issues; what is currently built is described in
  `CLAUDE.md`.
- **Ideas are not ADRs.** Things we might build go in `docs/ideas.md`
  with no ceremony. An idea becomes an ADR when we are deciding to do
  it, not when we are considering it.
- **Enforcement is mechanical.** Two Claude Code `PreToolUse` hooks
  (`task hook:guard-adr` on Edit/Write,
  `task hook:guard-adr-bash` on Bash) reject any agent write
  that touches an accepted ADR, or that would set an ADR's status by
  hand instead of through the scripts. `task adr:lint` runs in
  CI and fails on numbering gaps, missing TL;DR, invalid statuses,
  dangling supersession pointers, and an out-of-date index.

## Consequences

- Slower start on any architectural change: write the ADR, present
  it, wait for acceptance, then build. This is the point.
- The human is a hard dependency. Nothing architectural ships while
  they are away. Right for a solo or small project.
- The acceptance gate is a conversation, so it is only as strong as
  the agent's discipline in asking. The hooks cannot verify that the
  human said yes; they can only make the "yes" the sole path and
  freeze the file afterwards. ADR-0003 makes the asking mandatory.
- Typos in accepted ADRs live forever. Read before accepting.
- Rejected and superseded ADRs are kept. Knowing what was turned down
  is as useful as knowing what was picked.
- The hooks only bind Claude Code. A human with a text editor can
  still edit anything; the lint in CI is the backstop for that. The
  Bash guard is pattern-based; it raises the bar, it is not a sandbox.

## Alternatives considered

- **Decisions in `CLAUDE.md`.** Tried. It grows until nobody reads it,
  and the agent edits it freely, so the record is not stable.
- **Decisions in commit messages.** Not discoverable; the agent does
  not read history before acting.
- **Human edits the status line themselves.** Works for a technical
  human; excludes everyone else. The conversation is the interface.
- **No human gate on acceptance.** Tried by accident. See failure mode
  2.
