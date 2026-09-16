# ADR-0002: Honest status — nothing is described as done until it ships

- **Status:** Proposed
- **Date:** 2026-09-16
- **Supersedes:** —
- **Superseded by:** —

## TL;DR

Docs describe what is built, in present tense, only when it is built
and verified. Unbuilt = planned voice. ADRs carry decisions, not
status. `CLAUDE.md` "What is built" section is the one place present
tense is allowed, and it changes in the same PR as the code.

## Context

An AI agent reads the docs and *acts* on them. A README that says
"the contact form emails the owner" when the form is a stub sends the
agent off to build on top of a feature that does not exist, and sends
the human off to demo it. Aspirational present tense is not a
marketing smell here; it is an active hazard.

It also compounds with ADR-0001: ADRs are immutable, and an accepted
ADR will routinely describe behaviour that is not built yet. That is
correct and normal. The problem is only when something *other* than
an ADR — a README, a `CLAUDE.md`, a code comment — claims a thing
works.

## Decision

- Present tense means shipped and verified. Anything else is written
  as planned, in progress, or proposed, explicitly.
- `CLAUDE.md` carries a **What is built** section. It is the only
  authoritative present-tense description of the system. It is updated
  in the same pull request that changes the behaviour, never later.
- ADRs never carry status. An accepted ADR describing unbuilt
  behaviour is expected; status lives in issues and `CLAUDE.md`.
- A subagent's claim that "tests pass" or "it works" is a claim, not
  a fact, until CI or the human has reproduced it. Reviews check for
  present-tense claims that lack a corresponding shipped change.

## Consequences

- Docs read more cautiously and less impressively. Correct trade.
- Every behaviour-changing PR touches `CLAUDE.md`. Small friction,
  large payoff for the next session.
- Reviewers carry one more check.

## Alternatives considered

- **Write aspirationally, fix later.** Later never comes, and the
  agent acts on the aspiration in the meantime.
- **Track status inside ADRs.** Conflates the immutable decision
  record with the thing that changes most often. Rejected in ADR-0001.
