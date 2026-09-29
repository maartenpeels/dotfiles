# Neovim

Installed by `packages/neovim`. Config is `config/nvim/.config/nvim/`, based on
[LazyVim](https://www.lazyvim.org). Start `nvim` once after bootstrapping so lazy.nvim installs
the plugins.

The leader key is `space`. Press it and wait to see every binding (which-key). LazyVim's
defaults are listed at [lazyvim.org/keymaps](https://www.lazyvim.org/keymaps).

## What's added on top of LazyVim

| File                      | What it adds                                                       |
|---------------------------|--------------------------------------------------------------------|
| `plugins/colorscheme.lua` | Nord colour scheme                                                 |
| `plugins/fzf-lua.lua`     | fzf-lua as the picker, with the keys below                         |
| `plugins/diffview.lua`    | [diffview.nvim](https://github.com/sindrets/diffview.nvim), used by `git bd` and `git diffview` |

## Custom keys

These search from the directory nvim was started in, not the project root LazyVim detects:

| Key                | Action                    |
|--------------------|---------------------------|
| `<leader><space>`  | Find files                |
| `<leader>/`        | Grep                      |
| `<leader>;`        | Reopen the last picker    |

## Diffview

Opened by [`git bd` and `git diffview`](git.md#custom-commands), or directly:

| Command                    | Action                                   |
|----------------------------|------------------------------------------|
| `:DiffviewOpen`            | Uncommitted changes                      |
| `:DiffviewOpen main...`    | Everything since the branch left `main`  |
| `:DiffviewFileHistory %`   | History of the current file              |
| `:DiffviewClose`           | Close it                                 |

In the file panel, `tab`/`shift+tab` move between files and `-` stages or unstages one.

## Tools nvim uses

These come from `packages/`, see [CLI tools](cli-tools.md): ripgrep and fd (pickers), fzf
(fzf-lua), tree-sitter and a C compiler (building parsers), stylua (formatting Lua).

## Inside herdr

The [herdr-nvim](herdr/nvim.md) plugin runs this same config in a sidebar, and adds
`<leader>a…` keys there to send code comments to an agent.
