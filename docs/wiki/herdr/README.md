# herdr

[herdr](https://herdr.dev) is a terminal workspace manager for AI coding agents: tmux-style
workspaces, tabs and panes, which also know which panes run an agent (Claude Code, codex, ...)
and whether it's working, blocked or done.

Installed by `packages/herdr`, which also installs the plugins below and, on macOS, `alerter`
for Focus Notify. Only `config.toml` is in the repo (`config/herdr/`). Sockets, logs, sessions
and installed plugins stay in `~/.config/herdr/`, outside the repo.

## Getting started

```sh
herdr          # start, or attach to the running session
herdr status   # client and server versions, whether the server is running
```

Detaching (`prefix q`) leaves everything running. Run `herdr` again to come back.

## Keys

The prefix is `ctrl+a`, the same as [tmux](../tmux.md) (herdr's default is `ctrl+b`). While
you're inside herdr, programs don't receive `ctrl+a`: in zsh use `Home` to jump to the start of
the line, and nvim's increment-a-number (`ctrl+a`) is gone too.

**Can't remember a key? Press `prefix space`.** It opens
[which-key](which-key.md), which lists every key and every plugin action, and runs the one you pick.

### Added by this repo

Set in `config/herdr/.config/herdr/config.toml`:

| Key                        | Action                                                  |
|----------------------------|---------------------------------------------------------|
| `ctrl+a`                   | The prefix (herdr's default is `ctrl+b`)                |
| `prefix space`             | [which-key](which-key.md): every key and plugin action  |
| `prefix y`                 | lazygit in a popup over the current pane. `q` closes it |
| `prefix shift+y`           | Pick a pull request and review it in tuicr, in a pane that closes with it. See [Pull request review](../pr-review.md) |
| `prefix shift+v`           | Toggle [reviewr](reviewr.md) beside the current pane         |
| `prefix \|`                | Split side by side, like tmux (`prefix v` still works)  |
| `alt+←/→/↑/↓`              | Move between panes, no prefix, like tmux                |

The UI uses the Nord theme, to match tmux, Alacritty and nvim.

`prefix r` is still herdr's resize mode, not reload as in tmux. Reload is `prefix shift+r`.

### herdr's defaults

Everything else is unchanged. Run `herdr --default-config` for the full list.

| Key                        | Action                                 |
|----------------------------|----------------------------------------|
| `prefix ?`                 | Help                                   |
| `prefix g`                 | Go to any pane (lists agents by name)  |
| `prefix w`                 | Workspace picker                       |
| `prefix shift+n`           | New workspace                          |
| `prefix shift+g`           | New git worktree workspace             |
| `prefix c`                 | New tab                                |
| `prefix n` / `prefix p`    | Next / previous tab                    |
| `prefix 1`…`9`             | Go to tab N                            |
| `prefix v` / `prefix -`    | Split side by side / top and bottom    |
| `prefix h`/`j`/`k`/`l`     | Move between panes                     |
| `prefix z`                 | Zoom the pane                          |
| `prefix x`                 | Close the pane                         |
| `prefix b`                 | Toggle the sidebar                     |
| `prefix o`                 | Jump to the pane behind the last notification |
| `prefix e`                 | Open the scrollback in an editor       |
| `prefix [`                 | Copy mode                              |
| `prefix r`                 | Resize mode                            |
| `prefix q`                 | Detach                                 |
| `prefix shift+r`           | Reload `config.toml`                   |

## Plugins

| Plugin                            | ID                          | What it does                                          |
|-----------------------------------|-----------------------------|-------------------------------------------------------|
| [reviewr](reviewr.md)             | `persiyanov.reviewr`        | Review the agent's diff beside the chat, send line comments back |
| [herdr-nvim](nvim.md)             | `chmarax.herdr-nvim`        | nvim sidebar per tab, file picker, send code comments to an agent |
| [Auto Title](auto-title.md)       | `herdr.auto-title`          | Names tabs and panes after branch, program and agent task |
| [herdr-resurrect](resurrect.md)   | `ntindle.herdr-resurrect`   | Snapshots workspaces and brings back programs and agents after a restart |
| [Focus Notify](focus-notify.md)   | `herdr-focus-notify`        | macOS notification when an agent is blocked or done; click to jump to it (macOS only) |
| [which-key](which-key.md)         | `cowboyvang.which-key`      | Overlay of every key and plugin action (`prefix space`) |

Auto Title, Focus Notify and resurrect's autosave run on their own. reviewr and herdr-nvim open
panes, which you trigger with a plugin action.

### Running a plugin action

From inside herdr: `prefix space`, then `.` for **+plugins**, then the letter shown next to the
action. The letters are picked by which-key, so read them off the screen.

From a shell:

```sh
herdr plugin action list                                   # every action of every plugin
herdr plugin action invoke persiyanov.reviewr.toggle       # <plugin-id>.<action-id>
herdr plugin action invoke toggle --plugin persiyanov.reviewr   # same thing
```

With `--plugin`, the action ID has to come first. `--plugin x toggle` fails with
"unknown option".

The action runs in the background, so its output doesn't show up in your terminal. Read it with
`herdr plugin log list` (JSON, newest last).

### Binding an action to a key

For an action you use a lot, a direct key beats going through which-key. reviewr's toggle has
one (`prefix shift+v`). Add a block like this to `config/herdr/.config/herdr/config.toml`, then
press `prefix shift+r`:

```toml
[[keys.command]]
key = "prefix+shift+v"
type = "plugin_action"
command = "persiyanov.reviewr.toggle"   # <plugin-id>.<action-id>
description = "reviewr: toggle the diff review pane"
```

Several plugin READMEs suggest keys that herdr already uses: `prefix+e` and `prefix+o` in
herdr-nvim, and `prefix+R` (the same as `prefix shift+r`, reload config) in Auto Title. Pick
free keys, or accept that you lose the built-in one. On macOS, many terminals keep `alt+…` to
themselves; `cmd+…` chords reach herdr.

### Managing plugins

```sh
herdr plugin list                          # installed plugins, versions, config dirs
herdr plugin log list                      # output and exit code of every plugin command
herdr plugin disable <id>                  # turn one off without uninstalling
herdr plugin enable <id>
herdr plugin uninstall <id>
herdr plugin install <owner/repo> --yes    # what packages/herdr runs
```

To add a plugin for every machine, add its `owner/repo` to `PLUGINS` in `packages/herdr` and give
it a page here.

Plugin files live in `~/.config/herdr/plugins/github/`, each plugin's own config in
`~/.config/herdr/plugins/config/<id>/`, and state such as snapshots in
`~/.local/state/herdr/plugins/<id>/`.

### When a plugin doesn't work

1. `herdr plugin log list`, and look for `"status":"failed"` and its `stderr`.
2. Check the plugin's own requirements on its page.
3. Run its test or doctor action if it has one (Focus Notify `test`, `herdr-nvim doctor`).
