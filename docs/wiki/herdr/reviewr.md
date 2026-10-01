# reviewr

[persiyanov/herdr-reviewr](https://github.com/persiyanov/herdr-reviewr) · ID `persiyanov.reviewr`

A code-review pane next to your agent. Read the agent's diff, comment on lines, and send the
comments to the agent's input. It never edits files and never sends anything on its own.

## Opening it

`prefix shift+v` toggles it beside the current pane, in any workspace. It also opens by itself
when herdr creates a workspace for a git worktree (`prefix shift+g`). From a shell:

```sh
herdr plugin action invoke persiyanov.reviewr.toggle   # or .open / .close
```

It follows the git worktree of the workspace it's in.

## Reviewing a change

1. `j`/`k` picks a changed file in the navigator. `]` walks hunk by hunk across files.
2. `tab` moves focus to the diff.
3. `v`, then `j`/`k` to select lines (or drag in the line-number gutter).
4. `c`, type the comment, `enter`.
5. `s` sends all comments to the agent. With several agents in the workspace you pick one.

The footer shows the next step. `?` shows every key that works right now.

## Keys

| Key                | Action                                                           |
|--------------------|------------------------------------------------------------------|
| `1` `2` `3`        | Tab: Changes / All files / PR                                    |
| `u` `b` `t` `g`    | Scope: uncommitted / branch / last turn / commits                |
| `B`                | Pick the base branch for the branch scope                        |
| `G`                | Pick the commits to review                                       |
| `]` `[`            | Next / previous hunk                                             |
| `f` `F`            | Next / previous file                                             |
| `/`                | Search file names and code                                       |
| `ctrl+f`           | Find in the open file                                            |
| `v` `c` `e` `d`    | Select, comment, edit comment (or open the file in your editor), delete comment |
| `n` `N` `l`        | Next / previous comment, list comments                           |
| `s` `y`            | Send comments to the agent, copy them to the clipboard           |
| `m`                | Preview a markdown file                                          |
| `w`                | Toggle line wrap                                                 |
| `z`                | Hide the navigator                                               |
| `r`                | Refresh                                                          |
| `q`                | Quit                                                             |

## Scopes

| Scope          | Shows                                                                 |
|----------------|-----------------------------------------------------------------------|
| uncommitted    | Working tree vs `HEAD`, untracked files included (the default)        |
| branch         | Everything since the branch left the base branch, uncommitted included |
| last turn      | Only what changed since the agent's latest turn started               |
| commits        | One or more commits you pick with `G`                                 |

All scopes honour `.gitignore`.

The **PR** tab shows the branch's open pull request, read-only. It needs an authenticated `gh`
(GitHub), `glab` (GitLab) or `az` with the `azure-devops` extension (Azure DevOps).

## Config

`config/herdr/.config/herdr/plugins/config/persiyanov.reviewr/config.toml`, stowed to
`~/.config/herdr/plugins/config/persiyanov.reviewr/config.toml`. It sets the Nord theme and
`default_scope = "branch"`. Edits apply on the next refresh. Other options:

```toml
auto_open = false         # don't open on new worktree workspaces
editor = "nvim +{line} {file}"
```

reviewr's PR tab reads GitHub, GitLab and Azure DevOps, not Bitbucket. For reviewing a pull
request itself, on either host, use [tuicr](../pr-review.md).

## Gotchas

- Comments live only in the pane. Closing it loses any you haven't sent or copied.
- "Last turn" polls every 2 seconds, so a very short agent turn can be missed.
- It needs a true-colour terminal. Alacritty is fine.
