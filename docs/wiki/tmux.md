# tmux

Installed by `packages/tmux`. Config is `config/tmux/.tmux.conf`. Plugins are managed by
[tpm](https://github.com/tmux-plugins/tpm). The Nord theme is a git submodule, so
`bootstrap.sh` fetches it.

## Keys

The prefix is `ctrl+a` (not the default `ctrl+b`). Press `ctrl+a` twice to send a literal `ctrl+a`.

| Key                 | Action                         |
|---------------------|--------------------------------|
| `prefix \|`         | Split side by side             |
| `prefix -`          | Split top and bottom           |
| `alt+←/→/↑/↓`       | Move between panes (no prefix) |
| `prefix r`          | Reload `~/.tmux.conf`          |
| `prefix I`          | tpm: install plugins           |
| `prefix U`          | tpm: update plugins            |

Everything else is tmux's default: `prefix c` new window, `prefix n`/`p` next and previous
window, `prefix d` detach, `prefix z` zoom a pane, `prefix [` scroll mode.

## Settings

- 50,000 lines of scrollback.
- No escape delay, so `esc` in nvim is instant.
- True colour and focus events, so nvim inside tmux looks and behaves the same as outside.

For agent work, [herdr](herdr/README.md) replaces tmux. It's set up with the same prefix, `|` and
`-` splits, `alt+arrow` pane moves and Nord theme. Don't run tmux inside herdr: herdr takes
`ctrl+a` first, and tmux never sees it.
