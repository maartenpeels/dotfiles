# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## How it works

Stow creates symlinks from a **package directory** into a **target directory** (your `$HOME`).
Files inside `config/<package>/` mirror the structure of `$HOME` — so stow knows exactly where each symlink should land.

```
config/
└── git/
    └── .gitconfig          →  ~/.gitconfig
```

Stow does **not** copy files. It creates symlinks. Edit the file in this repo and the change is live immediately.

## Structure

```
dotfiles/
├── install             # stow all (or specific) packages into $HOME
└── config/
    └── git/            # one package per tool
        └── .gitconfig
```

Each directory under `config/` is a **stow package** — an isolated unit you can install or remove independently.

## Usage

```sh
# Stow everything
./install

# Stow a single package
./install git

# Unstow (remove symlinks for a package)
stow --dir=config --target=$HOME --delete git
```

## Conflicts with existing files

If files already exist at `$HOME` (not managed by stow), you'll see:

```
WARNING! stowing git would cause conflicts:
  * cannot stow .../.gitconfig over existing target .gitconfig since neither a link nor a directory
All operations aborted.
```

**Fix:** remove the originals first (they're already captured in the repo), then stow.

```sh
rm ~/.gitconfig
./install git
```

Alternatively, use `--adopt` to let stow absorb the existing files:

```sh
stow --dir=config --target=$HOME --adopt git
```

## Adding a new package

1. Create `config/<tool>/`
2. Mirror the target path inside it

```sh
# Example: add a zsh config
mkdir -p config/zsh
cp ~/.zshrc config/zsh/.zshrc

# Now stow it
./install zsh
```

The file `config/zsh/.zshrc` will be symlinked to `~/.zshrc`.

For files that live in `~/.config/` (XDG), mirror the full path:

```sh
mkdir -p config/alacritty/.config/alacritty
# → stows to ~/.config/alacritty/
```

## Prerequisites

```sh
brew install stow   # macOS
apt install stow    # Ubuntu/Debian
```
