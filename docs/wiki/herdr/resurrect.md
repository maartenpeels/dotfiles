# herdr-resurrect

[ntindle/herdr-resurrect](https://github.com/ntindle/herdr-resurrect) · ID `ntindle.herdr-resurrect`

tmux-resurrect for herdr. After a crash, reboot or `herdr server stop`, herdr brings back the
layout on its own, but only as empty shells. This plugin re-runs what was in them: dev servers,
`nvim`, and agents with their conversation (`claude --resume <id>`).

It needs `node` on `$PATH`, and `fzf` for the space picker.

## Snapshots

It saves a snapshot on its own whenever you open or close a workspace or pane, or an agent starts
(at most once every 20 seconds). The last 20 are kept, in
`~/.local/state/herdr/plugins/ntindle.herdr-resurrect/snapshots/`.

| Action                                  | What it does                                       |
|-----------------------------------------|----------------------------------------------------|
| `ntindle.herdr-resurrect.save`          | Save a snapshot now                                |
| `ntindle.herdr-resurrect.snapshots`     | List snapshots                                     |
| `ntindle.herdr-resurrect.restore-preview` | Show what a restore would do, change nothing     |
| `ntindle.herdr-resurrect.restore`       | Restore the newest snapshot                        |

Run them with `herdr plugin action invoke <action>`, and read the output with
`herdr plugin log list`.

### After a crash or reboot

1. Start `herdr`. The workspaces, tabs and panes come back as shells.
2. Run `restore-preview` to check the plan.
3. Run `restore`. It fills the empty panes and recreates workspaces that are missing entirely.

Running `restore` twice is safe: it only touches panes that are idle shells.

## Named spaces

Save a workspace layout under a name and open it again later as a new workspace, like
"debugging setup" or "client demo".

| Action                                  | What it does                                       |
|-----------------------------------------|----------------------------------------------------|
| `ntindle.herdr-resurrect.save-space`    | Save the current workspace under a name            |
| `ntindle.herdr-resurrect.open-space`    | Pick a saved space and open it as a new workspace  |
| `ntindle.herdr-resurrect.delete-space`  | Pick a saved space and delete it                   |

These open a picker, so bind them to keys (see
[Binding an action to a key](README.md#binding-an-action-to-a-key)) rather than running them from a
shell.

## Config

In `~/.config/herdr/plugins/config/ntindle.herdr-resurrect/`, created on first run:

- `settings.json`: set `"autoRestore": true` to restore on its own after herdr restarts (off by
  default).
- `allowlist.txt`: which programs get relaunched, one per line. Agents are always relaunched and
  don't need to be listed.
