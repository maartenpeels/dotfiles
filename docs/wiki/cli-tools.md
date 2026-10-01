# CLI tools

Small tools with one file each in `packages/` and no config in this repo.

| Tool            | Command       | What it's for                                                     |
|-----------------|---------------|-------------------------------------------------------------------|
| bat             | `bat`         | `cat` with syntax highlighting and line numbers. `bat -p` for plain output |
| fd              | `fd`          | Fast `find`. `fd config` finds paths matching "config", honouring `.gitignore`. On Ubuntu it's `fdfind` |
| ripgrep         | `rg`          | Fast `grep`. `rg TODO -t py` searches Python files only           |
| fzf             | `fzf`         | Fuzzy finder. Powers `ctrl+r`/`ctrl+t`/`alt+c` in [zsh](zsh.md), the pickers in [Neovim](neovim.md) and `git pr` |
| jq              | `jq`          | JSON processor. `git pr` uses it to read Bitbucket PR lists; reviewr needs it too |
| stow            | `stow`        | Symlinks `config/` into `$HOME`. See [Stow](../stow.md)          |
| stylua          | `stylua`      | Lua formatter, used by Neovim when you save a `.lua` file         |
| tree-sitter     | `tree-sitter` | Builds the parsers Neovim uses for syntax highlighting            |
| build-essential | `cc`/`gcc`    | C compiler: Xcode Command Line Tools on macOS, `build-essential` on Ubuntu. Needed to build tree-sitter parsers |
| JetBrains Mono Nerd Font | none | Terminal font with icons, used by [Alacritty](alacritty.md)   |

To add a tool, see [Package installation](../packages.md#adding-a-package).
