# Claude Code

Config is `config/claude/`, skills are installed by `packages/claude`. Claude Code itself isn't
installed by this repo.

`~/.claude` stays a real directory, because Claude keeps sessions, history, caches and memory there.
Stow links only these files into it:

| File                      | What it is                                                             |
|---------------------------|------------------------------------------------------------------------|
| `CLAUDE.md`               | Global instructions for every project                                 |
| `settings.json`           | Model, theme, plugins, marketplaces and hooks                         |
| `hooks/keep-awake.sh`     | Keeps the machine awake while Claude works on a prompt                |
| `hooks/herdr-subagent-pane.sh`, `hooks/subagent-transcript.py` | Shows each subagent in a split of its session's herdr pane |
| `skills/workstory/`       | `/workstory <story-id>`: one lead, one worker per ticket, in herdr    |

Changes made from inside Claude (`/config`, enabling a plugin) write through the symlink, so they
show up in `git diff`.

## Keep awake

`UserPromptSubmit` starts an inhibitor for the session: `caffeinate -is` on macOS (built in) or
`systemd-inhibit --what=idle:sleep` on Linux (part of systemd), so nothing needs installing.
`Stop`, `SessionEnd` and the `idle_prompt` notification (60 seconds waiting for input) stop it.
The inhibitor also exits when the Claude process does, so an interrupted prompt or a crash never
keeps the machine awake for long.

Closing the lid still sleeps the machine (on macOS, unless it's on power). Without either tool,
for example in a container without systemd, the hook does nothing.

## Skills

`packages/claude` installs these with the [skills CLI](https://skills.sh) (`npx skills`):

| Skill                           | From                       |
|---------------------------------|----------------------------|
| grill-me, tdd, improve-codebase-architecture, write-a-skill | `mattpocock/skills` |
| rust-skills                     | `leonardomso/rust-skills`  |
| cloud-solution-architect        | `microsoft/skills`         |
| vercel-composition-patterns     | `vercel-labs/agent-skills` |

Add one by adding a line to `SKILLS` in `packages/claude` and running `./install-packages claude`.

The AWS and `twg` skills come from their own installers, and `skills/synced` is managed by
claude.ai, so they aren't part of the repo.

## Subagents in herdr panes

`SubagentStart` runs `herdr-subagent-pane.sh`: inside herdr (`HERDR_ENV=1`) it splits the pane the
session runs in, wide panes to the right and tall ones down, and runs `subagent-transcript.py`
there, which follows the subagent's transcript and prints prompts, assistant text, tool calls and
the first line of each result. A second subagent splits the first viewer pane instead of the
session's pane again. `SubagentStop` closes the pane. Outside herdr both hooks do nothing.

Pane ids are kept under `~/.local/state/claude-herdr-subagents/<session-id>/` so the stop hook
finds the pane the start hook made.

## /workstory

`skills/workstory/SKILL.md` turns the session it runs in into the lead for a story (any tracker
issue with children). The lead writes `docs/plans/<story-id>.md` (tickets, dependencies,
contracts for every shared surface, waves), stops for approval, then starts one `claude` session
per ticket in its own herdr tab in the same workspace, each in its own worktree, each with
`worker-prompt.md` (filled in) as an appended system prompt and `AskUserQuestion` disallowed.

Workers talk to the lead with cross-session messaging (on by default since Claude Code 2.1.224).
Every question and every plan goes to the lead, which asks you and relays the answer; the lead
answers on its own only when the answer is literally in the approved plan. Plans of one wave are
reviewed together. Workers message each other directly on boundaries and copy the lead. You
merge; tell the lead "<ticket> merged" and it rebases dependents and cleans up.

A dependent ticket branches from its dependency's branch, so nothing waits for a merge. At most
four workers run at once. The lead uses `/triage`, `/workon` and `/parallel-work` when the
dev-loop plugin is installed and its own compact fallbacks when it isn't.

Both sides must run in the same permission class (both prompting, or both bypassing), otherwise
Claude Code holds their messages for approval instead of delivering them. Check once with two
sessions and `/list-agents` before trusting a story to it.

## herdr hook

`settings.json` also runs herdr's `herdr-agent-state.sh` on `SessionStart`. herdr owns that
script, so on a new machine run this once after bootstrapping:

```sh
herdr integration install claude
```
