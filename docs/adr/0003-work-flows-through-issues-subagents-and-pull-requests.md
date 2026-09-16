# ADR-0003: Work flows through issues, subagents, and pull requests

- **Status:** Proposed
- **Date:** 2026-09-16
- **Supersedes:** —
- **Superseded by:** —

## TL;DR

Accepted ADR, then issues, then code. Subagents write every code
change in a worktree and open a PR. Main Claude thread reviews and
merges, never authors implementation. No long-lived agents. Human
merges to `main` until CI is trusted.

## Context

Two things go wrong when one agent thread both writes and reviews
code. First, the author is a bad reviewer of its own diff; it already
believes the code is right. Second, the main thread fills its context
with implementation detail and loses the plot of the project. Both
have produced rework.

Splitting the roles fixes both. The main thread keeps the project
picture and reviews as an independent reader. Subagents carry the
implementation detail and discard it when done.

## Decision

1. **An ADR is accepted before implementation starts.** If something
   looks urgent enough to skip that, say so and let the human decide.
   Do not decide it yourself. Almost nothing is urgent.
2. **After acceptance, Claude opens issues** for the work the ADR
   implies. Issues are the work tracker; ADRs are not.
3. **Every code change goes through a subagent** — a typo, a one-line
   constant, a comment. The main thread does not write implementation
   code.
4. **Subagents work in git worktrees and open pull requests.** The
   main thread reviews, requests changes, and merges. Maximum five
   subagents in parallel.
5. **No long-lived agents.** Every subagent is new. None is reused
   across tasks or parked waiting for work.
6. **Build the current scope only.** Do not build ahead of the
   accepted ADR. Substitutions need a real reason, not a preference.
7. **Every PR links its issue and its ADR** in the description.

## Consequences

- More ceremony per change. A one-character fix still gets a
  subagent, a branch, and a PR. Accepted; the discipline is the value.
- Subagents work from a prompt, so the prompt must carry the relevant
  ADR and conventions. `CLAUDE.md` is loaded automatically; anything
  else must be pointed at explicitly.
- Parallel subagents can conflict. The main thread resolves conflicts
  at merge, which is why it must not also be an author.

## Alternatives considered

- **Main thread writes code directly.** Faster for the first hour,
  slower for the project. Rejected from experience.
- **One long-lived implementation agent.** Accumulates stale context
  and stale assumptions. Rejected.
