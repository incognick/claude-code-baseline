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

1. **The agent proposes.** `scripts/adr-new.sh "Title in the
   imperative"` creates the next-numbered file from the template with
   status `Proposed`.
2. **The agent presents it to the human in plain language** and asks a
   structured question: Accept / Reject / Change something.
3. **The human decides in conversation.** Only on an explicit Accept
   does the agent run `task adr:accept -- NNNN`, which records the
   date. Reject: `task adr:accept -- NNNN reject "reason"`. Silence
   is not acceptance.
4. **Accepted ADRs are immutable.** Hooks reject agent edits, from the
   editing tools and from the shell alike.
5. **Change happens by supersession.** Write a new ADR with
   `Supersedes: ADR-NNNN (fully | partially)`, get it accepted, then
   `task adr:supersede -- NNNN MMMM [partially]` applies the one
   permitted edit to the old file.
6. **After acceptance, the agent opens issues** for the implementation
   work the ADR implies.

An ADR that is never accepted stays `Proposed`, or is marked
`Rejected` with a one-line reason. Rejected ADRs are kept.

**Ideas are not ADRs.** Things we might build go in `docs/ideas.md`.

## Statuses

| Status | Meaning |
|---|---|
| `Proposed` | Written by the agent, awaiting the human. Not binding. |
| `Accepted` | The human approved it in conversation. Binding and frozen. |
| `Superseded by ADR-NNNN` | Fully replaced. Read the successor. |
| `Partially superseded by ADR-NNNN` | Still binding except where the successor overrides. The successor says exactly which part. |
| `Rejected` | Considered and declined. |

## Format

Every ADR follows `0000-template.md`. The non-negotiable part is the
**TL;DR** — the first section after the header: short, blunt, no
hedging. Someone skimming twenty ADRs reads only the TL;DRs and should
still come away knowing what this system is. The rest of the body is
normal prose.

## Tooling (run by the agent, defined in `Taskfile.yml`)

| Task | What it does |
|---|---|
| `task adr:new -- "Title"` | Create the next ADR from the template. |
| `task adr:accept -- NNNN [reject "reason"]` | Record the human's explicit decision. Adds the date. |
| `task adr:supersede -- OLD NEW [partially]` | Add the `Superseded by` pointer to ADR `OLD`. The only permitted edit to an accepted ADR. |
| `task adr:lint` | Check numbering, statuses, sections, supersession pointers, and the index. Runs in CI. |
| `task adr:index` | Regenerate the index below. |

## Index

Read the TL;DR of each. That is the point of the TL;DR.

<!-- adr-index:start -->
| # | Title | Status |
|---|---|---|
| [0001](0001-decisions-are-recorded-as-adrs.md) | Decisions are recorded as ADRs, and accepted ADRs are immutable | Proposed |
| [0002](0002-honest-status.md) | Honest status — nothing is described as done until it ships | Proposed |
| [0003](0003-the-agent-directs-subagents-and-the-human-directs-the-agent.md) | The agent directs subagents; the human directs the agent | Proposed |
| [0004](0004-the-agent-initializes-the-project-by-interview.md) | The agent initializes the project by interview | Proposed |
<!-- adr-index:end -->
