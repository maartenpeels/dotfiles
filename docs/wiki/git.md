# git

Config is `config/git/`. git itself isn't installed by this repo: on macOS it comes with the
Xcode Command Line Tools (`packages/build-essential`).

## Aliases

| Alias      | Runs                                          |
|------------|-----------------------------------------------|
| `git st`   | `status -sb`                                  |
| `git lg`   | `log --oneline --graph --decorate --all`      |
| `git co`   | `checkout`                                    |
| `git br`   | `branch`                                      |
| `git cp`   | `cherry-pick`                                 |
| `git undo` | `reset --soft HEAD~1` (undo the last commit, keep its changes staged) |
| `git bd`   | `branch-diff`, see below                      |

The zsh `git` plugin adds its own shorter aliases too (`gst`, `gco`, ...), see [zsh](zsh.md).

## Custom commands

These live in `config/git/.config/git/commands/`, which zsh puts on `$PATH`. Both open
[diffview in nvim](neovim.md#diffview).

| Command                          | Shows                                                                 |
|----------------------------------|-----------------------------------------------------------------------|
| `git bd [branch]`                | Everything this branch changed since it left `branch` (default: the repo's default branch). Like a PR diff |
| `git diffview`                   | Uncommitted changes                                                   |
| `git diffview <commit>`          | Changes since `<commit>`                                              |
| `git diffview <from> <to>`       | Changes between two commits                                           |

Untracked files are left out.

## Defaults worth knowing

| Setting                    | Effect                                                             |
|----------------------------|--------------------------------------------------------------------|
| `pull.rebase = true`       | `git pull` rebases instead of merging                              |
| `rebase.autoStash = true`  | Uncommitted changes are stashed and restored around a rebase       |
| `merge.ff = false`         | `git merge` always creates a merge commit                          |
| `push.autoSetupRemote`     | The first `git push` on a new branch sets its upstream             |
| `init.defaultBranch = main`|                                                                    |

## Identities per directory

`.gitconfig` picks the name, email and SSH key from where the repo lives:

| Repo location or remote                         | Included file            |
|-------------------------------------------------|--------------------------|
| `~/Projects/Personal/`                          | `.gitconfig-personal`    |
| `~/Projects/Work/`                              | `.gitconfig-work`        |
| `~/Projects/Work/LG/`                           | `.gitconfig-liberty`     |
| `~/Projects/Work/RTS/`                          | `.gitconfig-keen`        |
| remote on `ssh.dev.azure.com:v3/alfa1group`     | `.gitconfig-alfa1group`  |

Later matches override earlier ones, so a repo under `Work/LG/` gets the Liberty identity. Check
which one applies with `git config user.email` inside the repo.

## lazygit

Installed by `packages/lazygit`. Config is `config/lazygit/`, which only turns on Nerd Font v3
icons. Run `lazygit` in a repo and press `?` for its keys.

Inside [herdr](herdr/README.md), `prefix y` opens lazygit in a popup over the current pane. `q` closes
it.
