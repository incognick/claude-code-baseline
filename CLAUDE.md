# CLAUDE.md — Orientation for Claude Code sessions

This file tells you **what exists and how to work on it**. It does
**not** explain *why* anything is the way it is; the *why* lives in
`docs/adr/`.

## First: is the project initialized?

If `docs/UNINITIALIZED` exists, the project has not been set up.
Initialization is the only work until it is done. Follow
`docs/onboarding.md` exactly. Do not skip it because the human asked
for something else first; tell them the project needs setting up,
then set it up.

## Who you are working with

The human directing this project may not be a programmer. Assume they
will not read code, run commands, or interpret errors. They set
direction and answer questions. See ADR-0003.

- Speak plainly. No jargon without a one-clause explanation. No file
  paths, stack traces, or code in your replies unless asked.
- Every decision goes to them as a structured question with options
  to pick from and room to type their own. Never a decision buried in
  a paragraph. Batch questions at natural pauses.
- When they must do something outside this conversation (log in
  somewhere, pay for a domain, click a button), give exact
  step-by-step instructions.
- Report outcomes as they would experience them: a link, a
  screenshot, "you can now do X." Not "merged PR #12."

## Where the decisions live

`docs/adr/` is the decision log. Read `docs/adr/README.md` first. It
carries the process and an index with a one-line summary of every
decision. Before changing anything architectural, check whether an
ADR already covers it.

**The ADR process, in short (ADR-0001):**

- You **propose** ADRs: `task adr:new -- "Title in the imperative"`.
  Write the TL;DR blunt and short; the rest in normal prose.
- You **present** the ADR to the human in plain language — what is
  being decided, why, what it costs, the alternatives — and ask a
  structured question: **Accept** / **Reject** / **Change something**.
- Only on an explicit **Accept** do you run `task adr:accept -- NNNN`. On **Reject**, `task adr:accept -- NNNN reject "reason"`.
  On **Change**, edit the still-Proposed ADR and ask again. Silence,
  "ok", or "carry on" is not acceptance.
- Accepted ADRs are **immutable**. To change one, write a new ADR that
  supersedes it; once that is accepted, run
  `task adr:supersede -- OLD NEW [partially]`. That is the only
  edit the old file ever gets. Hooks block any other.
- ADRs never track status. After acceptance, open **issues** for the
  work the ADR implies.
- Ideas that are not yet decisions go in `docs/ideas.md`.

## What this project is

<!-- Filled in during initialization (docs/onboarding.md). -->

_Not yet initialized._

## The working loop (ADR-0003)

This is not optional and not a style preference. It is the process.

1. **An ADR is accepted before implementation starts.** If something
   looks urgent enough to skip that, say so plainly and let the human
   decide. Almost nothing is urgent.
2. **Accepted ADR, then issues, then code.** Issues are the tracker.
3. **You do not write implementation code.** Not a typo, not a
   one-line constant. Every code change goes to a fresh subagent on
   the cheaper model (`Agent` tool, `model: "sonnet"`), briefed with
   the issue, the relevant ADRs, the conventions, and the definition
   of done.
4. **Subagents work in git worktrees and open PRs.** You review each
   PR as an independent reader: does it do what the issue says,
   nothing more, in keeping with the ADRs? Request changes or merge.
   Max five subagents in parallel. Never reuse one.
5. **After merge, verify the outcome yourself** the way the human
   would see it — run it, open it, screenshot it. A subagent's "tests
   pass" is a claim until you have reproduced it. Update "What is
   built" below in the same change (ADR-0002).
6. **Report in plain language.** What changed, what they can now see
   or do, what is next, what needs them.

## How to work here

- **Follow the ADRs.** If the right move contradicts an accepted ADR,
  do not quietly deviate — propose a superseding ADR.
- **Build the current scope only.** Do not build ahead.
- **Substitutions need a real reason, not a preference.**
- **Decisions are justified from this project only.** What you know
  or remember about the human from elsewhere — other repositories,
  profile, chat memory — is not a reason. If it seems relevant, offer
  it as an option and let them choose.
- **Propose, don't ask, for things you can verify yourself.** Ask when
  it changes what the project is, what it costs, or who it is for.
- **Honest status (ADR-0002).** Present tense means shipped and
  verified.
- `task` is the entrypoint for everything, including the ADR tooling.
  `task --list` shows what exists. Wire the stack's build, test, and
  lint into `task test` / `task lint` once the stack ADR is accepted.

## Enforcement

- `.claude/settings.json` registers two `PreToolUse` hooks.
  `task hook:guard-adr` (Edit/Write) blocks edits to accepted
  or superseded ADRs and blocks hand-written status changes.
  `task hook:guard-adr-bash` (Bash) blocks shell writes to
  `docs/adr/` except through the `task adr:*` tasks. If a hook blocks you,
  it is right; do what its message says.
- `task adr:lint` runs in CI on every PR.

## Traps

<!-- Each entry should have cost real time. Add them as they happen. -->

- (none yet)

## What is built

Nothing user-facing. Only the process: ADRs, their tooling, the hooks,
and CI for the lint. Stack and hosting are undecided until their ADRs
exist and are accepted.

## What is next

Initialization (`docs/onboarding.md`), then the stack ADR.
