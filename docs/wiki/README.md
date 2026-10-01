# Wiki

What each tool in this repo is for, how it's set up, and how to use it day to day.

For how the repo itself works, see [Stow: config management](../stow.md) and
[Package installation](../packages.md).

## Shell and terminal

| Page                        | What it covers                                                        |
|-----------------------------|-----------------------------------------------------------------------|
| [zsh](zsh.md)               | oh-my-zsh, powerlevel10k, plugins, `cd`/`ls`/`..`, `~/.zshrc.local`   |
| [Alacritty](alacritty.md)   | Terminal emulator: Nord theme, JetBrains Mono Nerd Font               |
| [tmux](tmux.md)             | `ctrl+a` prefix, splits, pane navigation, tpm                         |

## Editing and git

| Page                        | What it covers                                                        |
|-----------------------------|-----------------------------------------------------------------------|
| [Neovim](neovim.md)         | LazyVim, custom pickers, diffview                                     |
| [git](git.md)               | Aliases, per-directory identities, `git bd`, `git diffview`, lazygit  |
| [Pull request review](pr-review.md) | `git pr`: review GitHub and Bitbucket PRs in tuicr, `prefix shift+y` in herdr |
| [CLI tools](cli-tools.md)   | bat, fd, ripgrep, fzf, jq, stow, stylua, tree-sitter, build tools, font |

## AI agents

| Page                        | What it covers                                                        |
|-----------------------------|-----------------------------------------------------------------------|
| [Claude Code](claude.md)    | Global `CLAUDE.md`, settings, keep-awake hook, skills            |

## herdr (AI agent workspaces)

| Page                                        | What it covers                                        |
|---------------------------------------------|-------------------------------------------------------|
| [herdr](herdr/README.md)                    | What herdr is, default keys, managing plugins         |
| [reviewr](herdr/reviewr.md)                 | Review agent diffs and send line comments back        |
| [herdr-nvim](herdr/nvim.md)                 | nvim sidebar, file picker, code annotations           |
| [Auto Title](herdr/auto-title.md)           | Tabs and panes named after the work in them           |
| [herdr-resurrect](herdr/resurrect.md)       | Snapshot and restore workspaces, named spaces         |
| [Focus Notify](herdr/focus-notify.md)       | Clickable macOS notifications when an agent needs you |
| [which-key](herdr/which-key.md)             | `prefix space`: every key and plugin action, runnable |

## Where things come from

| Tool                                       | Installed by (`packages/`) | Config (`config/`) |
|--------------------------------------------|----------------------------|--------------------|
| zsh, oh-my-zsh, p10k, zsh plugins          | `zsh`                      | `zsh`, `p10k`      |
| Alacritty                                  | not installed by the repo  | `alacritty`        |
| tmux                                       | `tmux`                     | `tmux`             |
| Neovim                                     | `neovim`                   | `nvim`             |
| git                                        | not installed by the repo  | `git`              |
| lazygit                                    | `lazygit`                  | `lazygit`          |
| tuicr, bkt (Bitbucket CLI)                 | `tuicr`                    | `tuicr`            |
| herdr, its plugins, alerter (macOS)        | `herdr`                    | `herdr`            |
| Claude Code skills                         | `claude`                   | `claude`           |
| bat, fd, ripgrep, fzf, jq, stow, stylua, tree-sitter, build-essential, JetBrains Mono Nerd Font | one file each | none |
