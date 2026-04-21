# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick start

```sh
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` installs packages and stows all configs.

## Structure

```
dotfiles/
├── bootstrap.sh        # install packages + stow configs
├── install             # stow configs only
├── install-packages    # install CLI tools (brew / apt)
├── packages/           # one file per tool
└── config/             # one directory per stow package
```

## Docs

- [Stow — config management](docs/stow.md)
- [Package installation](docs/packages.md)
- [Worktree management](docs/worktree.md)
