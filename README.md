# claude-code-baseline

Build a website or an app by describing what you want. You do not
need to know how to code. You do not need to have used a terminal.

This is a starting folder for [Claude Code](https://claude.com/claude-code)
that turns it into a careful collaborator: it asks before deciding
anything important, writes every decision down where it cannot later
quietly change it, and reports back in plain language.

---

## Part 1 — For you, the person building something

### What you get

- An assistant that interviews you about what you want, picks
  sensible technology for it, and explains the choice in plain words.
- A written record of every important decision, in plain language,
  that you approved. The assistant cannot change a decision once you
  have approved it; it can only propose a new one.
- Results you can see — a link, a screenshot, "you can now do X" —
  not code.

### Getting started (about 10 minutes)

**1. Get Claude Code.** Download the desktop app for Mac or Windows
from [claude.com/claude-code](https://claude.com/claude-code) and sign
in. You need a paid Claude plan.

**2. Get this folder.** At the top of this page click the green
**Code** button, then **Download ZIP**. Unzip it and rename the folder
to whatever you want to call your project. (If you have a GitHub
account and prefer it: click **Use this template** instead.)

**3. Open the folder in Claude Code** and type anything — "hi" is
fine.

**4. Answer its questions.** It will notice the project has not been
set up yet and ask you: what to call it, what it is for, what kind of
thing it is, and which technology to use (it will recommend one). It
will check what tools are installed on your computer and offer to
install anything missing — it asks first, every time.

**5. Approve the first decision.** It will show you a short summary
of the technology it recommends and why, with the choices *Accept*,
*Reject*, or *Change something*. Pick one. That is the whole
approval process, and it repeats for every important decision from
here on.

Then describe what you want to build.

### How decisions work

Every important choice — which technology, where the site runs, how
people sign in, what is free and what is paid — gets written down as
a short document called an **ADR** (architecture decision record).
Each one says, in plain language, what was decided, why, what it
costs, and what else was considered.

The assistant writes the ADR, explains it to you, and asks. Only your
explicit *Accept* approves it. Once approved it is frozen: the
assistant cannot edit it, even a little. A guard in this folder
enforces that mechanically, not just by asking nicely.

**Why bother?** Because the assistant forgets everything between
sessions. Without a written record it re-decides things from scratch,
undoes good choices, and drifts. With the record, every session starts
from what you already agreed to.

### Questions you will have

**What if I change my mind about a decision?**
Say so. The assistant writes a *new* ADR that replaces the old one,
explains what changes, and asks you to approve it. The old one stays
in the folder, marked as replaced, so you can always see what you
used to think and why. Nothing is ever deleted or rewritten.

**What if I don't understand a decision it is proposing?**
Pick *Change something* and say "explain it more simply" or ask what
happens if you choose differently. It will not proceed until you
choose.

**Do I have to read code?**
No. If it shows you code without being asked, tell it to stop; that is
against its own rules.

**Will it install things on my computer without asking?**
No. It lists what is missing and asks you, tool by tool, whether it
may install it, showing exactly what it will run. You can also say
"I'll do it myself" and get step-by-step instructions.

**Can it break something?**
It works inside your project folder. It will ask before doing
anything that costs money (buying a domain, signing up for a
service) or anything outside the folder.

**What does it cost?**
Claude Code needs a paid Claude plan. Most small websites and apps can
be hosted for free; a web address (like `yourbusiness.com`) costs
around $12 a year. The assistant will tell you before anything costs
money.

**Mac or Windows?**
Both. Claude Code's desktop app runs on either. On Windows, if it asks
to install "Git for Windows," say yes — it provides tools the
assistant relies on.

**I have used a terminal before. Is there a shorter way?**

```sh
gh repo create my-project --template incognick/claude-code-baseline --clone
cd my-project
claude
```

---

## Part 2 — For the agent, and for people changing this template

### What this is

A process, not a stack. The stack is the first decision a fresh copy
makes. What the template fixes is *how* decisions are made and kept:

1. One decision, one ADR. Blunt summary at the top.
2. The agent proposes and asks. The human accepts or rejects in
   conversation. Silence is not acceptance.
3. Accepted ADRs are frozen. New ADRs supersede old ones.
4. ADRs are not to-do lists. Issues track work.
5. Nothing is described as done until it ships and was verified.
6. The main agent directs; subagents write code; the main agent
   reviews. The human never reads code or runs commands.

Each rule is itself an ADR in `docs/adr/`, so changing a rule goes
through the same process as any other decision.

### Layout

| Path | What it is |
|---|---|
| `CLAUDE.md` | How the agent works here. Loaded every session. Start there. |
| `docs/UNINITIALIZED` | Marker: fresh copy, not set up. The agent removes it at the end of onboarding. |
| `docs/onboarding.md` | The setup interview the agent runs when the marker exists (ADR-0004). |
| `docs/adr/` | The decision log. Process in `README.md`, template in `0000-template.md`. |
| `docs/adr/0001` … `0004` | The process itself, recorded as decisions. |
| `docs/ideas.md` | Scratch list. Not decisions. |
| `Taskfile.yml` | Every command the agent runs: `task adr:new / accept / supersede / index / lint`, the two hooks, `task lint`, `task test`. |
| `.claude/settings.json` | Registers the hooks as Claude Code `PreToolUse` hooks. |
| `.github/workflows/ci.yml` | Runs `task adr:lint` on every PR. |
| `.github/PULL_REQUEST_TEMPLATE.md` | Every PR names its issue and its ADR. |

### Enforcement

Two Claude Code hooks, both defined in `Taskfile.yml` and invoked with
`task --exit-code`:

- `hook:guard-adr` (Edit / Write / MultiEdit): rejects edits to any
  accepted or superseded ADR, and rejects hand-written status changes.
- `hook:guard-adr-bash` (Bash): rejects shell writes to `docs/adr/`
  (`sed -i`, redirects, heredocs, `rm`, `mv`) except through the
  `task adr:*` tasks.

Status changes happen only via `task adr:accept` and
`task adr:supersede`. `task adr:lint` runs in CI and fails on
numbering gaps, invalid statuses, missing sections, dangling
supersession pointers, missing acceptance stamps, and a stale index.

The hooks bind Claude Code only. A human with an editor can change
anything; CI lint and review are the backstop. The Bash guard is
pattern-based — it raises the bar, it is not a sandbox. The
acceptance gate is a conversation; the hooks make the accept task the
only path and freeze the file afterwards, but cannot verify the human
said yes. ADR-0003 makes the asking mandatory.

### Requirements

[Task](https://taskfile.dev), `bash`, and one of `python3`, `node`, or
`jq` (the hooks parse JSON with whichever exists). On Windows, Git
Bash. The onboarding step detects and offers to install these.

### Changing this template

Open an issue or a PR. Changes to the process go through the
process: propose an ADR. See `CONTRIBUTING.md`.

### License

CC0 — public domain. Copy it, rename it, delete the license file. No
attribution needed. The agent removes `LICENSE` and `CONTRIBUTING.md`
during onboarding.
