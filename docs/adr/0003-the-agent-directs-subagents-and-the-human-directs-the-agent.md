# ADR-0003: The agent directs subagents; the human directs the agent

- **Status:** Proposed
- **Date:** 2026-09-16
- **Supersedes:** —
- **Superseded by:** —

## TL;DR

Human sets direction in plain language and answers questions. Main
agent (strongest model) plans, reviews, merges, reports. Subagents
(cheaper model) write every line of code in worktrees and open PRs.
Human never reads code. Every decision goes to human as question with
options. Accepted ADR, then issues, then code.

## Context

The human directing this project may not be a programmer and may
never review a diff. That removes the usual safety net — a human
reading the code — and replaces it with a different one: a main agent
that never writes implementation code, so it can review as an
independent reader with its full attention on the project rather than
on the last function it wrote.

Two things go wrong when one agent thread both writes and reviews.
The author is a bad reviewer of its own diff; it already believes the
code is right. And the main thread fills its context with
implementation detail and loses the plot of the project. Both have
produced rework.

The human's time is the scarce resource and their attention is
non-technical. Questions to them must be rare, concrete, and
answerable by picking an option.

## Decision

**Roles.**

- **The human** owns direction: what the project is for, who it
  serves, what matters more than what. They answer questions and
  accept or reject ADRs. They are never asked to read code, run
  commands, or interpret errors. If they must do something outside
  the conversation (log in to a service, pay for a domain), the agent
  gives exact click-by-click steps.
- **The main agent** — the strongest available model — plans, writes
  ADRs, opens issues, briefs subagents, reviews their pull requests,
  merges, verifies the result, and reports back in plain language. It
  does not write implementation code. Not a typo, not a one-line
  constant.
- **Subagents** — a cheaper model, one per task, never reused — write
  every code change in a git worktree and open a pull request with a
  clear description of what they did and how they verified it. Their
  claims are claims until the main agent verifies them.

**Loop.**

1. A decision that shapes the system gets an ADR. It is accepted
   before implementation starts (ADR-0001). If something looks urgent
   enough to skip that, the agent says so and lets the human decide.
   Almost nothing is urgent.
2. After acceptance, the main agent opens issues for the work the ADR
   implies. Issues are the tracker; ADRs are not.
3. For each issue, the main agent briefs a fresh subagent: the issue,
   the relevant ADRs, the conventions, the definition of done.
   At most five subagents run in parallel.
4. The subagent works in a worktree and opens a PR. The main agent
   reviews it as a reader: does it do what the issue says, nothing
   more, in keeping with the ADRs? It requests changes or merges.
5. After merge the main agent verifies the outcome the way the human
   would experience it — a URL, a screenshot, a behaviour — not by
   trusting the PR description. `CLAUDE.md`'s "What is built" is
   updated in the same change (ADR-0002).
6. The main agent reports to the human in plain language: what
   changed, what they can now see or do, what is next, what needs
   them.

**Talking to the human.**

- Every decision goes through a structured question with options the
  human can pick from, plus room to type their own. Never a decision
  buried in a paragraph.
- Plain language. No jargon without a one-clause explanation. No
  code, stack traces, or file paths unless the human asks.
- Batch questions. Ask several at once at a natural pause rather than
  one at a time across an hour.
- Propose, don't ask, for anything the agent can verify itself. Ask
  when it changes what the project is, what it costs, or who it is
  for.
- Build the current scope only. Substitutions need a real reason, not
  a preference.

## Consequences

- More ceremony per change. A one-character fix still gets a
  subagent, a branch, and a PR. The discipline is the value.
- The main agent's review is the only code review. Its brief to the
  subagent and its reading of the PR carry the quality. `CLAUDE.md`
  is loaded automatically; anything else the subagent needs must be
  in the brief.
- Parallel subagents can conflict; the main agent resolves conflicts
  at merge, which is why it must not also be an author.
- Cost: the main agent is the expensive model and stays in the loop
  for every change. Acceptable; it is doing the thinking.
- The human can steer the project anywhere they like, including
  somewhere unwise. The agent's job is to say so once, plainly, with
  the cost, and then do what they decide.

## Alternatives considered

- **Main thread writes code directly.** Faster for the first hour,
  slower for the project. Rejected from experience.
- **One long-lived implementation agent.** Accumulates stale context
  and stale assumptions. Rejected.
- **Ask the human to review PRs.** They will not, or cannot. Designing
  as if they will is designing for a different user.
