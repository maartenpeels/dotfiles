# Pull request review

Review pull requests in the terminal with [tuicr](https://tuicr.dev), on GitHub and Bitbucket
Cloud alike. `git pr` picks one of the repo's open pull requests and opens it; in
[herdr](herdr/README.md) that is `prefix shift+y`.

Installed by `packages/tuicr` (tuicr, and `bkt` for Bitbucket) and `packages/jq`. Config is
`config/tuicr/` (Nord theme, unified diff). The `git pr` command is
`config/git/.config/git/commands/git-pr`.

## One-time setup

tuicr detects the host from the repo's `upstream` or `origin` remote and talks to it through a
CLI that has to be logged in:

| Host             | tuicr uses | `git pr` lists with | Log in once with                                             |
|------------------|------------|---------------------|--------------------------------------------------------------|
| GitHub           | `gh`       | `gh`                | `gh auth login`                                              |
| Bitbucket Cloud  | `bkt`      | `twg`               | `bkt auth login https://bitbucket.org --kind cloud --web-token` and `twg auth login` |

For `bkt`, create an **API token** (not a general one) with `Account: Read`, `Pull requests: Read`
and, to submit reviews, `Pull requests: Write`. Check with `bkt auth status`. Then give `bkt` an
active context, or tuicr fails with "no active context" (its docs say a context is optional, but
bkt 0.32 insists). The host is the key `bkt auth status` prints, not `bitbucket.org`:

```sh
bkt context create merapar --host https://api.bitbucket.org/2.0 --workspace merapar --set-active
```

`gh` and `twg` aren't installed by this repo.

## Opening a pull request

```sh
git pr          # pick from the open pull requests with fzf
git pr 42       # open #42 directly
git pr -l       # just print the list
```

Run it inside a clone of the repo: tuicr needs the remote to know which host and repository to
read, but it fetches the pull request itself and never touches your working tree or branch.

Inside herdr, `prefix shift+y` runs `git pr` in a temporary zoomed pane, in the directory of the
pane you were in. The pane closes when tuicr exits, so the layout is back to what it was. Press
the key itself: which-key lists it but can't run pane commands ("herdr owns this pane").

tuicr has its own picker too: `:prs` from inside tuicr lists pull requests, and `r` there narrows
it to the ones requesting your review.

## Reviewing

`?` shows every key. The ones you need:

| Key                  | Action                                                        |
|----------------------|---------------------------------------------------------------|
| `tab` / `shift+tab`  | Focus the next / previous panel (file tree, diff, comments)   |
| `h` at column 0      | Open the file tree and focus it. `l` or `enter` in the tree goes back to the diff |
| `j` / `k`            | Move                                                          |
| `]` / `[`            | Next / previous hunk                                          |
| `}` / `{`            | Next / previous file                                          |
| `c` / `C`            | Comment on the line / on the whole file                       |
| `v`, then `c`        | Select a range of lines, then comment on it                   |
| `m` / `M`            | Next / previous comment                                       |
| `dd`                 | Delete the comment under the cursor                           |
| `r` / `R`            | Mark the file / hunk as reviewed                              |
| `/`                  | Search                                                        |
| `:diff`              | Unified or side by side                                       |
| `y`                  | Copy the whole review to the clipboard as markdown            |
| `:submit`            | Post the review to the host, see below                        |
| `:w` / `:q` / `:wq`  | Save the session / quit / both. Sessions come back with `:sessions` |

`:submit` asks for the review type: **Comment**, **Approve**, **Request changes** or **Draft**.
Inline comments land on their lines, a review-level comment becomes the summary. `:submit approve`
and the others skip the picker.

## Bitbucket differences

- `:submit` offers **Comment** and **Approve** only. To request changes, post the comments and
  request changes in Bitbucket.
- Bitbucket Cloud only. Data Center is not supported.
- Approving needs you to be a reviewer on the pull request; otherwise the comments are posted and
  the approval is rejected.
- Reviewers show up by full name, Bitbucket doesn't return handles.

## With Claude

Nothing runs on its own. When a change needs more than reading:

1. Start Claude in a pane next to tuicr, in the repo (or `prefix shift+g` for a worktree workspace
   on the branch).
2. `y` in tuicr, paste. The markdown has file and line anchors, so "is this a real bug?", "does
   anything else call this?" or "draft a fix for these" have the right context.
3. What gets posted is still your `:submit`.

A Claude session can also drop draft comments straight into the open tuicr session with
`tuicr review add` (see `tuicr review --help`); they appear like your own, tagged with the name you
give. Ask for it when you want a second pair of eyes before you start reading.

## Gotchas

- herdr runs key commands with `/bin/sh` and a bare `PATH`, so the binding uses the script's full
  path and the script adds Homebrew, `~/.local/bin` and mise's shims to `PATH` itself. A tool
  installed elsewhere needs adding there.
- `git pr` lists at most 100 open pull requests on GitHub; on Bitbucket, whatever `twg` returns.
- A repo with both `upstream` and `origin` is read through `upstream`. Pass
  `tuicr pr 42 --remote origin` to override.
- "Unsaved changes" on `:q` means comments you haven't submitted or saved. `:w` keeps them for
  `:sessions`, `q` again discards.
- Re-running `tuicr pr` for the same pull request reopens the saved session, comments included.
