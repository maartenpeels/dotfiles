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
├── install                 # stow all (or specific) packages into $HOME
├── config/
│   ├── git/                # one package per tool
│   │   └── .gitconfig
│   └── scripts/            # worktree + config injection tools
│       └── .local/
│           ├── bin/
│           │   ├── wt          # worktree lifecycle manager
│           │   ├── config      # stow-based config injector
│           │   └── init-local  # scaffold a new -local repo
│           └── lib/
│               └── workspace.sh  # shared context detection
└── templates/
    └── project-local/      # skeleton for new project -local repos
        └── local/
            └── bin/
                └── bootstrap
```

Each directory under `config/` is a **stow package** — an isolated unit you can install or remove independently.

## Usage

```sh
# Stow everything
./install

# Stow a single package
./install git
./install scripts

# Unstow (remove symlinks for a package)
stow --dir=config --target=$HOME --delete git
```

## Adding a new package

1. Create `config/<tool>/`
2. Mirror the target path inside it

```sh
# Example: add a zsh config
mkdir -p config/zsh
cp ~/.zshrc config/zsh/.zshrc
./install zsh
```

For files that live in `~/.config/` (XDG), mirror the full path:

```sh
mkdir -p config/alacritty/.config/alacritty
# → stows to ~/.config/alacritty/
```

## Conflicts with existing files

If a file already exists at `$HOME` (not managed by stow):

```
WARNING! stowing git would cause conflicts:
  * cannot stow .../.gitconfig over existing target ...
```

Remove the original first, then stow. Or use `--adopt` to absorb it:

```sh
stow --dir=config --target=$HOME --adopt git
```

---

## Worktree management

The `scripts` package ships three tools: `wt`, `config`, and `init-local`. After running `./install scripts`, all land in `~/.local/bin/` (ensure this is in your `$PATH`).

These tools implement a **workspace pattern** where each project lives alongside a companion `-local` repo that holds private, local-only configuration:

```
workspace/
├── myproject/              # main repo (committed, shared)
├── myproject-local/        # local config repo (not pushed)
│   ├── .gitignore
│   ├── mise.local.toml     # env vars, tool overrides
│   ├── .claude/
│   │   └── settings.local.json
│   └── local/
│       └── bin/
│           └── bootstrap   # project-specific setup script
└── feature-branch/         # worktree created by `wt add`
```

### wt — worktree lifecycle

```sh
wt add <branch>    # create worktree + run bootstrap
wt go              # fzf picker to navigate between worktrees
wt status          # list all worktrees with branch and git status
wt rm [branch]     # remove worktree (unstows config first, fzf if no arg)
```

Context detection is automatic — `wt` works from inside any worktree, the main repo, the `-local` repo, or the parent workspace directory.

### config — config injection

Stows the `-local` repo into a worktree (or any target directory):

```sh
config install [target]   # stow -local configs into target
config remove [target]    # unstow configs from target
```

`target` can be a worktree name, absolute path, or omitted for fzf selection. `wt add` calls this automatically via `bootstrap`. `wt rm` calls `config remove` before deleting the worktree.

### init-local — scaffold a new -local repo

Run from inside any project repo:

```sh
cd workspace/myproject
init-local
```

This creates `myproject-local/` next to the project with a `.gitignore`, a `bootstrap` template, and an initial commit. Then:

1. Edit `local/bin/bootstrap` to add project-specific setup steps (mise, npm install, etc.).
2. Add any files you want injected into worktrees directly to the root of the `-local` repo (stow will symlink them). For example:

```
myproject-local/
├── mise.local.toml              # → worktree/mise.local.toml
└── .claude/
    └── settings.local.json      # → worktree/.claude/settings.local.json
```

3. From inside `myproject/`, create your first worktree:

```sh
wt add my-feature
```

This creates `workspace/my-feature/`, runs `config install` to stow the `-local` configs into it, then runs any additional steps in `bootstrap`.

### New project quickstart

```sh
# 1. Install the scripts package (one-time)
cd ~/dotfiles && ./install scripts

# 2. Scaffold the -local repo from inside your project
cd workspace/myproject
init-local

# 3. Add files to inject into every worktree
echo 'AWS_PROFILE = "dev"' > ../myproject-local/mise.local.toml

# 4. Edit the bootstrap script to add setup steps
$EDITOR ../myproject-local/local/bin/bootstrap

# 5. Create a worktree — bootstrap runs automatically
wt add my-feature
# → creates workspace/my-feature/
# → stows myproject-local/ into it
# → runs bootstrap
```

## Prerequisites

```sh
brew install stow fzf   # macOS
apt install stow fzf    # Ubuntu/Debian
```
