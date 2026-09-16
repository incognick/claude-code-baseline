# ADR-0004: The agent initializes the project by interview

- **Status:** Proposed
- **Date:** 2026-09-16
- **Supersedes:** —
- **Superseded by:** —

## TL;DR

Fresh copy of template has marker file `docs/UNINITIALIZED`. Agent
sees it, tells human project not set up, interviews with option
questions: name, purpose, audience, language/framework, hosting
later. Detects tools, offers install. Strips template-only files,
writes README and CLAUDE.md, proposes stack ADR. Removes marker last.

## Context

This repository is a template. Every project starts as a copy of it,
and every copy needs the same first hour: name it, decide the stack,
install the tools, remove the parts that only made sense for the
template. A human who is not a programmer cannot do that hour alone,
and should not have to. The agent can, if it knows the copy is fresh
and has a script for the conversation.

## Decision

- **Marker.** The template ships `docs/UNINITIALIZED`. Its presence
  means "not yet set up." The agent checks for it at the start of
  every session; if it exists, initialization is the only work until
  it is done. Deleting it is the last step.
- **Announce.** The agent tells the human, in one short paragraph,
  that the project has not been set up yet and that it will ask a few
  questions to do so.
- **Interview**, as structured questions with options and a free-text
  fallback, batched into as few rounds as possible:
  1. Project name (suggest the folder name).
  2. One sentence: what it is and who it is for.
  3. Kind of thing: a website (marketing / brochure), a web app
     (people log in and do things), a command-line tool, an API, or
     something else they describe.
  4. Language and framework. Offer a short list appropriate to the
     kind chosen, each with one plain-language line on why someone
     would pick it, plus "you choose for me" and free text. The agent
     may recommend one and say why.
  5. Where it should run, if they already know. Otherwise defer;
     hosting is its own ADR after the stack is settled.
  6. Whether the project is private or public.
- **Tools.** The agent detects what the chosen stack needs (`git`,
  the language runtime, its package manager, `gh`, `task`) and reports
  what is present and what is missing. For anything missing it asks:
  install it for you (with the exact command it will run), or you
  install it (with click-by-click steps). It never installs without
  an explicit yes.
- **Strip and write.** The agent removes `LICENSE` and
  `CONTRIBUTING.md` (the template is public-domain, so nothing is
  owed), replaces `README.md` with a project stub built from the
  answers, fills the "What this project is" section of `CLAUDE.md`,
  and records nothing as built.
- **First ADR.** The agent writes the stack ADR from the answers and
  presents it for acceptance per ADR-0001. Hosting follows as its own
  ADR when the human is ready.
- **Finish.** The agent deletes `docs/UNINITIALIZED`, commits, and
  reports what was set up and what happens next.

## Consequences

- One more file in the template and one more check at session start.
  Trivial.
- The interview is opinionated about what to ask. Projects that do
  not fit the "website / web app / CLI / API" shape use the free-text
  path; the agent adapts.
- Tool installation is a real action on the human's machine. The
  explicit-yes rule is load-bearing.
- A human who copies the template and never opens Claude Code gets a
  repository with a marker file in it. Harmless.

## Alternatives considered

- **A shell script that strips the template.** Tried. It handles the
  mechanical part and none of the conversation, and the human still
  has to run it.
- **No marker; detect freshness from `CLAUDE.md` placeholders.**
  Fragile; the agent may have partially filled them in. An explicit
  marker is unambiguous.
