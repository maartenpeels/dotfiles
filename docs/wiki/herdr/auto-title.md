# Auto Title

[kryptamine/herdr-auto-title](https://github.com/kryptamine/herdr-auto-title) · ID `herdr.auto-title`

Names tabs and panes after the work in them. It runs on its own; there's nothing to press.

```
~/work/dashboard                       →  1 · dashboard
~/work/dashboard on feature/MC-13200   →  2 · dashboard › MC-13200
nvim editing auth.provider.ts          →  3 · nvim › auth.provider.ts
an agent working on OAuth scopes       →  4 · dashboard › claude › Implement OAuth scopes
```

- The number is the tab's position, so `prefix 4` goes to tab 4.
- The default branch is left out. Long branch names are cut down to the ticket (`MC-13675`).
- Every pane gets its own name too, so `prefix g` lists agents by what they're doing instead of
  "claude, claude, claude".
- Rename a tab or pane yourself and Auto Title leaves it alone. Clear the name to hand it back.

## Restarting

Restart it after changing its config, or when tabs stop being renamed:

```sh
herdr plugin action invoke herdr.auto-title.restart
```

## Config

Optional, in `~/.config/herdr-auto-title/config.env` (not the directory `herdr plugin list`
prints). Copy `config.env.example` from the plugin directory and uncomment what you need:

| Setting                          | Default | Effect                                             |
|----------------------------------|---------|----------------------------------------------------|
| `HERDR_AUTO_TITLE_MAX_LENGTH`    | `50`    | Longest title, in columns                          |
| `HERDR_AUTO_TITLE_BRANCH_MAX`    | `12`    | Longest branch in a title; `0` hides branches      |
| `HERDR_AUTO_TITLE_POSITION`      | `true`  | Tab number in front of the title                   |
| `HERDR_AUTO_TITLE_AGENT_NAME`    | `true`  | Agent name in front of what it's doing             |
| `HERDR_AUTO_TITLE_WORKSPACES`    | `false` | Also rename a workspace that holds a single tab    |
