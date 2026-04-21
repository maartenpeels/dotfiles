# Worktree management

The `scripts` package ships three tools: `wt`, `config`, and `init-local`. After `./install scripts`, they land in `~/.local/bin/` (ensure it's in `$PATH`).

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
wt add <branch>    # create worktree + run bootstrap
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

## init-local — scaffold a -local repo

Run from inside any project:

```sh
cd workspace/myproject
init-local
```

Creates `myproject-local/` with a `bootstrap` template, and initial commit.

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
init-local

# 4. Edit bootstrap
$EDITOR ../myproject-local/local/bin/bootstrap

# 5. Create a worktree — bootstrap runs automatically
wt add my-feature
```

