# Alacritty

Config is `config/alacritty/.config/alacritty/`. Alacritty itself isn't installed by this repo:
`brew install --cask alacritty`.

| Setting | Value                                                                  |
|---------|------------------------------------------------------------------------|
| Theme   | Nord, from `themes/nord.toml`                                          |
| Font    | JetBrainsMono Nerd Font Mono, 13pt (installed by `packages/font-jetbrains-mono-nerd`) |
| Shell   | `/bin/zsh`                                                             |
| `TERM`  | `xterm-256color`                                                       |

The Nerd Font is what makes the icons in the prompt, lazygit, reviewr and `eza` render.
Alacritty reloads the config as soon as you save it.
