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

Add one by adding a line to `SKILLS` in `packages/claude` and running `./install-packages claude`.

The AWS and `twg` skills come from their own installers, and `skills/synced` is managed by
claude.ai, so they aren't part of the repo.

## herdr hook

`settings.json` also runs herdr's `herdr-agent-state.sh` on `SessionStart`. herdr owns that
script, so on a new machine run this once after bootstrapping:

```sh
herdr integration install claude
```
