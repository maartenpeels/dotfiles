# dotfiles

Personal dotfiles for macOS and Ubuntu/Debian, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick start

```sh
git clone https://github.com/maartenpeels/dotfiles.git
cd dotfiles
./bootstrap.sh
```

The repo can live anywhere; the scripts resolve paths relative to themselves.

`bootstrap.sh` fetches submodules, installs packages (Homebrew on macOS, apt on Linux) and stows every
package in `config/` into `$HOME`. It's safe to re-run: installed tools are skipped.

After bootstrapping:

- Open a new shell. If zsh isn't your login shell yet, the installer prints the `chsh` command to run.
- Start `nvim` once so lazy.nvim installs its plugins.

## What's included

| Package     | Config                                                                        |
|-------------|-------------------------------------------------------------------------------|
| `zsh`       | `.zshrc`: oh-my-zsh, powerlevel10k, autosuggestions, syntax highlighting       |
| `p10k`      | `.p10k.zsh`: powerlevel10k prompt config (regenerate with `p10k configure`)   |
| `git`       | `.gitconfig`, per-directory identities, global ignore, `git bd` / `git diffview` / `git pr` |
| `nvim`      | LazyVim-based Neovim config                                                   |
| `tmux`      | `.tmux.conf` with tpm and the Nord theme                                      |
| `alacritty` | Alacritty config and Nord theme                                               |
| `lazygit`   | lazygit config                                                                |
| `tuicr`     | tuicr config (Nord theme); tuicr and bkt are installed by `packages/tuicr`     |
| `herdr`     | herdr config (`config.toml` only); plugins are listed in `packages/herdr`     |
| `claude`    | Claude Code `CLAUDE.md`, `settings.json` and hooks; skills in `packages/claude` |

## Machine-specific config

`.zshrc` only contains config that works on every machine. Tool integrations (mise, fzf, direnv,
terraform) load only when the tool is installed.

Anything specific to one machine goes in `~/.zshrc.local`, which is sourced last and is not part of
this repo. For example: SDK paths, `JAVA_HOME`, work-specific tools, or tokens.

```sh
# ~/.zshrc.local
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
```

Installers that append to `~/.zshrc` write into this repo through the symlink, so `git diff` shows
them. Move those lines to `~/.zshrc.local`.

## Structure

```
dotfiles/
├── bootstrap.sh        # submodules + install packages + stow configs
├── install             # stow configs only (all, or: ./install zsh git)
├── install-packages    # install tools (all, or: ./install-packages fzf)
├── packages/           # one file per tool
└── config/             # one directory per stow package
```

## Docs

- [Wiki: every tool and plugin, and how to use it](docs/wiki/README.md)
- [Stow: config management](docs/stow.md)
- [Package installation](docs/packages.md)
