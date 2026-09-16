# Architecture Decision Records

This directory is the decision log. If you want to know *why*
something is the way it is, the answer lives here — not in
`CLAUDE.md`, not in a code comment, not in a commit message.

## What an ADR is (and is not)

An ADR records **one decision**: the context that forced it, the call
that was made, and what that call costs. It is a historical document.

An ADR is **not** a task tracker. It never says "done", "in progress",
"shipped", or "TODO". Implementation is tracked in issues. `CLAUDE.md`
records what is currently built. An ADR records only what was decided
and why.

## Process

The process is itself ADR-0001. In short:

1. **Claude proposes.** `task adr:new -- "Title in the imperative"`
   creates the next-numbered file from the template with status
   `Proposed`. Claude never marks an ADR `Accepted`.
2. **The human accepts.** `task adr:accept -- NNNN` (or
   `task adr:accept -- NNNN reject "reason"`). The script refuses to
   run without an interactive terminal, so the agent's shell cannot
   call it. Editing the status line by hand is equally fine — the
   hooks only bind the agent, not you. Silence is not acceptance.
3. **Accepted ADRs are immutable.** The file is frozen. Claude Code
   hooks reject agent edits to it, from the Edit/Write tools and from
   the shell alike.
4. **Change happens by supersession.** Write a new ADR with
   `Supersedes: ADR-NNNN (fully | partially)`, get it accepted, then
   run `task adr:supersede -- NNNN MMMM`. That script applies the one
   permitted edit to the old file.
5. **After acceptance, Claude opens issues** for the implementation
   work the ADR implies.

An ADR that is never accepted stays `Proposed`, or is marked
`Rejected` with a one-line reason. Rejected ADRs are kept.

**Ideas are not ADRs.** Things we might build go in `docs/ideas.md`.

## Statuses

| Status | Meaning |
|---|---|
| `Proposed` | Written by Claude, awaiting the human. Not binding. |
| `Accepted` | The human approved it. Binding and frozen. |
| `Superseded by ADR-NNNN` | Fully replaced. Read the successor. |
| `Partially superseded by ADR-NNNN` | Still binding except where the successor overrides. The successor says exactly which part. |
| `Rejected` | Considered and declined. |

## Format

Every ADR follows `0000-template.md`. The non-negotiable part is the
**TL;DR** — the first section after the header, written in caveman:
short, blunt, no articles, no hedging. Someone skimming twenty ADRs
reads only the TL;DRs and should still come away knowing what this
system is. The rest of the body is normal prose.

## Tooling

| Command | What it does |
|---|---|
| `task adr:new -- "Title"` | Create the next ADR from the template. |
| `task adr:accept -- NNNN [reject "reason"]` | Human only. Move a Proposed ADR to Accepted or Rejected. Needs a terminal. |
| `task adr:supersede -- OLD NEW` | Add the `Superseded by` pointer to ADR `OLD`. The only permitted edit to an accepted ADR. |
| `task adr:lint` | Check numbering, statuses, TL;DR presence, supersession pointers, and that the index below is in sync. Runs in CI. |
| `task adr:index` | Regenerate the index below. |

## Index

Read the TL;DR of each. That is the point of the TL;DR.

<!-- adr-index:start -->
| # | Title | Status |
|---|---|---|
| [0001](0001-decisions-are-recorded-as-adrs.md) | Decisions are recorded as ADRs, and accepted ADRs are immutable | Proposed |
| [0002](0002-honest-status.md) | Honest status — nothing is described as done until it ships | Proposed |
| [0003](0003-work-flows-through-issues-subagents-and-pull-requests.md) | Work flows through issues, subagents, and pull requests | Proposed |
<!-- adr-index:end -->
