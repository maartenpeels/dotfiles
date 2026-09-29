# Focus Notify

[yankewei/herdr-focus-notify](https://github.com/yankewei/herdr-focus-notify) · ID `herdr-focus-notify`
· macOS only

Shows a macOS notification when an agent is **blocked** (it needs your input) or **done**.
Clicking it brings the terminal forward and focuses that agent's pane. There's nothing to
configure.

It skips the notification when you're already looking at that pane, and removes it once you get
there.

## Requirements

[alerter](https://github.com/vjeantet/alerter) shows the notifications. `packages/herdr` installs
it on macOS (`brew install vjeantet/tap/alerter`). Without it, every event fails with
`no alerter notifier found`.

The first notification may make macOS ask whether alerter can send notifications. Allow it, or
turn it on later under System Settings → Notifications → alerter.

## Checking it works

```sh
herdr plugin action invoke herdr-focus-notify.test
```

This sends a real test notification.

## Which terminal a click brings forward

The plugin learns this on its own. The first time you focus a pane in a workspace, it remembers
which terminal app was in front. A click then activates that app.

If a click brings forward the wrong terminal (for example after switching terminal apps), clear
what it learned and focus a pane once in the right terminal:

```sh
herdr plugin action invoke herdr-focus-notify.clear-terminal-bindings
```

In Alacritty a click activates the app, and macOS picks which window comes forward. Only iTerm2
and kitty (with remote control on) can jump to the exact window or tab.
