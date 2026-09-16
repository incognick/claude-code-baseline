# claude-code-baseline

A starting point for building a website or app with
[Claude Code](https://docs.anthropic.com/en/docs/claude-code) without
losing track of *why* anything was decided.

It is not a stack. It is the process that sits in front of one:
architecture decision records that the agent proposes and a human
accepts, a hook that stops the agent editing decisions after the fact,
and a working loop where subagents write code and the main session
reviews it.

## Use it

Click **Use this template** on GitHub, or:

```sh
gh repo create my-project --template incognick/claude-code-baseline --clone
cd my-project
task init -- my-project
```

`task init` removes the files that only make sense for the template
(this README's setup section, `CONTRIBUTING.md`, `LICENSE`, and
itself) and leaves you a project that reads as yours.

Requires [Task](https://taskfile.dev) and one of `python3`, `node`, or `jq` (the hook parses JSON with whichever exists).
Scripts are plain bash; on Windows use Git Bash or WSL.

Nothing here assumes a language. TypeScript, Python, Go, Rust — the
stack is your first ADR, and `task test` / `task lint` are where it
plugs in.

Then open Claude Code in the directory and start with:

> Read CLAUDE.md and docs/adr/README.md. Propose an ADR for the stack.

Accept or reject what it proposes with `task adr:accept -- NNNN` in
your own terminal (the script refuses to run from the agent's shell).
That is the whole trick: the agent cannot accept its own decisions,
and cannot change accepted ones — hooks block the Edit tool and the
shell alike.

## What is in here

| Path | What it is |
|---|---|
| `CLAUDE.md` | What exists and how to work on it. Loaded by Claude Code every session. |
| `docs/adr/` | The decision log. Process in `README.md`, template in `0000-template.md`. |
| `docs/adr/0001` … `0003` | The process itself, recorded as ADRs. Accept them or supersede them. |
| `docs/ideas.md` | Scratch list. Not decisions. |
| `scripts/adr-*.sh` | Create, accept (human only), supersede, index, lint. Wrapped by `task adr:*`. |
| `scripts/hooks/guard-adr*.sh` | Claude Code hooks: accepted ADRs are read-only to the agent, via Edit or shell; only a human accepts. |
| `.claude/settings.json` | Registers the hook. |
| `.github/workflows/ci.yml` | Runs the ADR lint on every PR. |
| `.github/PULL_REQUEST_TEMPLATE.md` | Every PR names its issue and its ADR. |
| `Taskfile.yml` | The only entrypoint. |
| `scripts/init.sh` | `task init`: strips template-only files. Deletes itself. |

## The rules, in one screen

1. One decision, one ADR. Caveman TL;DR at the top.
2. Claude proposes. A human accepts. Silence is not acceptance.
3. Accepted ADRs are frozen. Supersede, never edit.
4. ADRs record decisions, not status. Issues track work.
5. Nothing is described as done until it ships.
6. Subagents write code and open PRs. The main session reviews.

Each rule is an ADR in `docs/adr/`, so if you disagree with one, the
process for changing it is already there.

## License

CC0 — public domain. Fork it, rename it, delete the license file, no
attribution needed.
