# zsh

Installed by `packages/zsh`: zsh itself, oh-my-zsh, the powerlevel10k theme and two plugins.
Config is `config/zsh/.zshrc` and `config/p10k/.p10k.zsh`.

If zsh isn't your login shell yet, the installer prints the `chsh` command to run.

## Plugins

| Plugin                    | What it does                                                             |
|---------------------------|--------------------------------------------------------------------------|
| `git`                     | oh-my-zsh git aliases (`gst`, `gco`, `gp`, `gl`, ...). Run `alias \| grep git` to see them |
| `nvm`                     | Loads nvm lazily. Does nothing when nvm isn't installed                  |
| `zsh-autosuggestions`     | Grey suggestion from history as you type. `→` or `End` accepts it         |
| `zsh-syntax-highlighting` | Colours the command line as you type; red means the command wasn't found |

## Prompt

powerlevel10k. To change it, run `p10k configure`. That rewrites `~/.p10k.zsh`, which is a symlink
into this repo, so commit the result.

## Changed built-ins

| Command | Behaviour                                                                                  |
|---------|--------------------------------------------------------------------------------------------|
| `cd`    | Changes directory, lists it, and pushes it onto the directory stack                        |
| `..`    | **Goes back to the previous directory** (pops the stack), not up to the parent. Use `cd ..` for the parent |
| `ls`    | Uses `eza` with icons and git status when it's installed, otherwise coloured `ls -a`. eza isn't installed by this repo: `brew install eza` |

## Tool integrations

Each loads only when the tool is installed:

| Tool        | What you get                                                           |
|-------------|------------------------------------------------------------------------|
| `fzf`       | `ctrl+r` fuzzy history, `ctrl+t` insert a file path, `alt+c` cd into a directory |
| `mise`      | Per-project tool versions                                              |
| `direnv`    | Loads `.envrc` when you enter a directory                              |
| `terraform` | Tab completion                                                         |

`$PATH` gets `~/.local/bin`, `~/go/bin` and `~/.config/git/commands` (for the custom
[git commands](git.md#custom-commands)).

## Machine-specific config

Put anything that belongs to one machine in `~/.zshrc.local`. It's sourced last and isn't in the
repo. See the [README](../../README.md#machine-specific-config).
