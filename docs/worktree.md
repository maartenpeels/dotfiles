# Worktree management

The `scripts` package ships two tools: `wt` and `config`. After `./install scripts`, they land in `~/.local/bin/` (ensure it's in `$PATH`).

Each project lives alongside a companion `-local` repo holding private, local-only config:

```
workspace/
├── myproject/              # main repo (committed, shared)
├── myproject-local/        # local config (not pushed)
│   ├── .gitignore
│   ├── mise.local.toml
│   ├── .claude/
│   │   └── settings.local.json
│   └── local/bin/bootstrap
└── feature-branch/         # worktree created by `wt add`
```

Context detection is automatic — `wt` works from inside any worktree, the main repo, the `-local` repo, or the parent workspace directory.

## wt — worktree lifecycle

```sh
wt setup           # scaffold a -local config repo for the current project
wt add <branch>    # create worktree + run bootstrap
wt ls              # pick a worktree with fzf, pre-fills cd on next prompt
wt dev <branch>    # open dev workspace
wt status          # list all worktrees with branch and git status
wt rm <branch>     # remove worktree (unstows config first, fzf if no arg)
```

## config — config injection

Stows the `-local` repo into a worktree:

```sh
config install <target>   # stow -local configs into target
config remove <target>    # unstow configs from target
```

`target` is a worktree name, absolute path, or omitted for fzf selection. `wt add` and `wt rm` call this automatically.

## wt setup — scaffold a -local repo

Run from inside any project:

```sh
cd workspace/myproject
wt setup
```

Creates `myproject-local/` with a `bootstrap` template, `.claude/settings.local.json`, and initial commit.

Then:
1. Edit `local/bin/bootstrap` for project-specific setup (mise, npm install, etc.)
2. Add files to inject into every worktree (stow symlinks them):

```
myproject-local/
├── mise.local.toml              # → worktree/mise.local.toml
└── .claude/
    └── settings.local.json      # → worktree/.claude/settings.local.json
```

## Quickstart

```sh
# 1. Install scripts package (one-time)
./install scripts

# 2. Scaffold the -local repo
cd workspace/myproject
wt setup

# 3. Edit bootstrap
$EDITOR ../myproject-local/local/bin/bootstrap

# 4. Create a worktree — bootstrap runs automatically
wt add my-feature
```

