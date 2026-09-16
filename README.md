# claude-code-baseline

A starting point for building a website or app with
[Claude Code](https://docs.anthropic.com/en/docs/claude-code) when
you are the director, not the programmer.

You describe what you want and answer questions. The agent proposes
decisions in plain language, you accept or reject them, and it records
them where it cannot later change them. Cheaper subagents write the
code; the main agent reviews it; you see results, not diffs.

## Use it

On GitHub, click **Use this template**, then open the new folder in
Claude Code and say anything — "hi" is enough. The agent will notice
the project has not been set up, ask you a few questions (name, what
it is for, what kind of thing it is, which language), check which
tools are installed and offer to install what is missing, and propose
the first decision for you to accept.

If you prefer the terminal:

```sh
gh repo create my-project --template incognick/claude-code-baseline --clone
cd my-project
claude
```

## What is in here

| Path | What it is |
|---|---|
| `CLAUDE.md` | How the agent works here. Loaded every session. |
| `docs/UNINITIALIZED` | Marker: project not set up yet. The agent removes it when done. |
| `docs/onboarding.md` | The setup interview the agent runs. |
| `docs/adr/` | The decision log. Process in `README.md`, template in `0000-template.md`. |
| `docs/adr/0001` … `0004` | The process itself, recorded as decisions. Accept them or supersede them. |
| `docs/ideas.md` | Scratch list. Not decisions. |
| `scripts/adr-*.sh` | Create, accept, supersede, index, lint. The agent runs these. |
| `scripts/hooks/` | Claude Code hooks: accepted decisions are read-only to the agent. |
| `.claude/settings.json` | Registers the hooks. |
| `.github/workflows/ci.yml` | Lints the decision log on every PR. |
| `Taskfile.yml` | `task lint`, `task test`. The agent wires the stack in. |

## The rules, in one screen

1. One decision, one record. Blunt summary at the top.
2. The agent proposes and asks. You accept or reject. Silence is not yes.
3. Accepted decisions are frozen. New decisions supersede old ones.
4. Decisions are not to-do lists. Issues track work.
5. Nothing is described as done until it ships and was checked.
6. The main agent directs; subagents write code; the main agent reviews.
7. You are never asked to read code or run commands.

Each rule is a decision in `docs/adr/`, so if you disagree with one,
the process for changing it is already there.

## License

CC0 — public domain. Copy it, rename it, delete this file. No
attribution needed. The agent removes the license file during setup.
