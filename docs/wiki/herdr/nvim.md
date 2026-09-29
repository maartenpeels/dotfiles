# herdr-nvim

[ChmaraX/herdr-nvim](https://github.com/ChmaraX/herdr-nvim) · ID `chmarax.herdr-nvim`

A full-height nvim sidebar in each herdr tab, a picker for the files the agent touched, and code
comments you write in nvim and send to the agent.

## The sidebar

```sh
herdr plugin action invoke chmarax.herdr-nvim.toggle
```

Your panes move to one half and nvim takes the other. Toggle it again and the layout comes back.
Each tab has its own nvim that keeps running while hidden, so buffers and cursor survive the
toggle. Closing the tab stops that nvim and **discards unsaved buffers**.

The sidebar loads your normal [Neovim config](../neovim.md).

## Opening the files the agent touched

```sh
herdr plugin action invoke chmarax.herdr-nvim.pick-file
```

A popup lists the files touched this session, newest first, with `+N -M` diff stats. `enter`
opens the top one in the sidebar. Start typing to fuzzy-search the whole repo instead.

File paths in agent output are also clickable (`src/app.ts:42`, `file://…`). A click opens the
file in the sidebar at that line.

## Sending code comments to the agent

Inside the sidebar nvim:

| Key           | Command         | Action                                                  |
|---------------|-----------------|---------------------------------------------------------|
| `<leader>ac`  | `:Herdr comment`| Comment the current line or selection                   |
| `<leader>al`  | `:Herdr list`   | List comments: `enter` edits, `d` deletes               |
| `<leader>as`  | `:Herdr send`   | Paste all comments into the agent's input               |
| `<leader>aS`  | `:Herdr submit` | Send all comments and submit them                       |
| `<leader>ai`  | `:Herdr ref`    | Insert `path:12-20` at the agent's cursor, without sending |

Each sent comment carries its file, line, repo and branch. If more than one agent could be meant,
you pick one. Comments are kept in memory and cleared after sending.

These keys only exist in the sidebar nvim. To get them in a normal `nvim` too, add
`{ "ChmaraX/herdr-nvim", opts = {} }` to the Neovim plugins.

## Managing the background nvims

```sh
herdr-nvim daemons                   # which tab each nvim belongs to, and its memory use
herdr-nvim daemons stop --orphans    # stop the ones whose tab is gone
herdr-nvim doctor                    # check that the sidebar works
```

`herdr-nvim` is in `~/.config/herdr/plugins/github/chmarax.herdr-nvim-*/bin/`, which isn't on
`$PATH`, so call it by full path.

## Config

Optional, in `~/.config/herdr-nvim/config.toml`: sidebar position (`right` by default), the nvim
binary, and how many files the picker lists.
