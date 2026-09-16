# Onboarding — how the agent initializes a fresh project (ADR-0004)

Run this when `docs/UNINITIALIZED` exists. Do all of it. Delete the
marker only at the end.

## 1. Announce

One short paragraph to the human: this project has not been set up
yet; you will ask a few questions and then set it up; it takes a few
minutes.

## 2. Interview

Use structured questions with options and a free-text fallback. Batch
into two rounds at most.

**Round one.**

1. **Project name.** Suggest the folder name as the first option.
2. **What is it, and who is it for?** One sentence. Free text, with
   two or three example sentences as options to show the shape.
3. **What kind of thing is it?**
   - A website — pages people read; contact form at most.
   - A web app — people sign in and do things.
   - A command-line tool — runs in a terminal.
   - An API — other programs talk to it.
   - Something else (describe).
4. **Private or public** on GitHub.

**Round two** (options depend on round one).

5. **Language and framework.** Offer three or four fitting choices,
   each with one plain-language line on why someone picks it, plus
   "you choose for me" and free text. Recommend one and say why.
   Examples of fitting lists:
   - Website: Astro (fast, simple, mostly plain HTML) · Next.js
     (popular, more moving parts) · Hugo (Go-based, very fast builds)
     · plain HTML and CSS.
   - Web app: Next.js with TypeScript · Rails · Django · Go with
     server-rendered templates.
   - CLI: Go · Python · Rust · Node/TypeScript.
   - API: Go · Python (FastAPI) · Node/TypeScript · Rails API.
6. **Where should it run?** Offer "decide later" first. If they know,
   capture it; hosting still gets its own ADR after the stack.

## 3. Detect tools

Check what the chosen stack needs. Typically `git`, the runtime
(node / python3 / go / ruby / cargo), its package manager, `gh`, and
`task`. Report in plain language what is present and what is
missing. For each missing tool ask, as a structured question:

- **Install it for me** — show the exact command you will run.
- **I'll install it** — give click-by-click steps for their OS.
- **Skip for now.**

Never install without an explicit yes. Never use `sudo` without
saying so in the question.

## 4. Strip the template

- Delete `LICENSE` and `CONTRIBUTING.md`. The template is public
  domain; nothing is owed.
- Replace `README.md` with a project stub: name, the one sentence,
  "Built with Claude Code. Decisions live in `docs/adr/`."
- Fill the "What this project is" section of `CLAUDE.md` from the
  answers: what it is, who it is for, private or public. Leave "What
  is built" as nothing.
- Add stack-appropriate lines to `.gitignore`.

## 5. Propose the stack ADR

`task adr:new -- "Build with <language> and <framework>"`. Write
it from the answers: context (kind of thing, audience), decision
(language, framework, package manager, how it is run locally, how
tests run), consequences, alternatives (the other options offered and
why not). Present it per ADR-0001 and ask Accept / Reject / Change.

Do not start the hosting ADR in the same round unless the human
already chose hosting in the interview.

## 6. Finish

- Delete `docs/UNINITIALIZED`.
- Commit everything with the message `Initialize <name> from
  claude-code-baseline`.
- If the human wants the repository on GitHub and `gh` is available,
  offer to create it (private or public per their answer). Ask first.
- Report: what was set up, which ADR is waiting for their answer if
  any, and what happens next.
