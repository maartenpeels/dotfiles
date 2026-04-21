# Stow — config management

Stow creates symlinks from `config/<package>/` into `$HOME`. Edit files in this repo; changes are live immediately.

```
config/
└── git/
    └── .gitconfig          →  ~/.gitconfig
```

## Structure

```
dotfiles/
├── install                 # stow all (or specific) packages
├── config/
│   ├── git/
│   │   └── .gitconfig
│   └── scripts/
│       └── .local/
│           ├── bin/
│           │   ├── wt
│           │   ├── config
│           │   └── init-local
│           └── lib/
│               └── workspace.sh
└── templates/
    └── project-local/
```

## Usage

```sh
./install           # stow all packages
./install git       # stow a single package

# Remove symlinks
stow --dir=config --target=$HOME --delete git
```

## Adding a new package

1. Create `config/<tool>/`
2. Mirror the target path inside it

```sh
mkdir -p config/zsh
cp ~/.zshrc config/zsh/.zshrc
./install zsh
```

For XDG paths (`~/.config/`):

```sh
mkdir -p config/alacritty/.config/alacritty
# stows to ~/.config/alacritty/
```

## Conflicts

If a file already exists at the target:

```
WARNING! stowing git would cause conflicts:
  * cannot stow .../.gitconfig over existing target ...
```

Remove the original, or adopt it:

```sh
stow --dir=config --target=$HOME --adopt git
```
