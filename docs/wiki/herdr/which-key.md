# which-key

[CowboyVang/herdr-which-key](https://github.com/CowboyVang/herdr-which-key) · ID `cowboyvang.which-key`

An overlay like Neovim's which-key. Press `prefix space` to see every herdr key, grouped:
herdr's defaults, the keys this repo adds, and every plugin action, including the ones with no key
of their own. Press the next key to run it. `esc` goes back or closes.

## Screens

| Key (after `prefix space`) | Screen                                                                  |
|----------------------------|-------------------------------------------------------------------------|
| any herdr key              | Runs it, as if you'd pressed `prefix` and that key                      |
| `.`                        | **+plugins**: every action of every installed plugin                    |
| `m`                        | **+herdr sub-modes**: the keys inside copy mode, resize mode and so on  |
| `shift+s`                  | **+workspaces**: jump to a workspace                                    |
| `shift+b`                  | **+tabs**: jump to a tab                                                |
| `!`                        | **+doctor**: keymap health                                              |

which-key picks the keys for its own screens and for the entries under **+plugins** from whatever
herdr leaves free. They're always shown next to what they do, but they can change when you add
a key or a plugin.

Entries marked `·` are herdr's own UI modes (copy mode, settings, ...). which-key can't trigger
those, so it tells you which key to press instead. The same goes for popups such as `prefix y`
(lazygit).

## Checking it

```sh
sh ~/.config/herdr/plugins/config/cowboyvang.which-key/launch.sh doctor
```

It reports keys with no description, bindings that point at plugin actions that aren't installed,
and useful herdr actions that have no key.

It currently warns that the plugin was built against herdr 0.7.5, and you run 0.9.1. It still
reads the keys from the installed herdr, so the list is right. Only some labels and the sub-mode
screens may be slightly out of date.

## How it's wired up

herdr doesn't let plugins claim keys, so the key lives in `config.toml` as a `popup` binding that
runs `~/.config/herdr/plugins/config/cowboyvang.which-key/launch.sh`.

The plugin's install step writes that launcher while the plugin is still in herdr's temporary
checkout, so the path inside it is wrong. `packages/herdr` rewrites it after installing. If
`prefix space` fails with "can't open file ... .tmp-install-...", run:

```sh
python3 ~/.config/herdr/plugins/github/cowboyvang.which-key-*/bin/which-key install-launcher
```

## Your own groups

You can add groups of your own, like `g` for git or `p` for panes, in
`~/.config/herdr/plugins/config/cowboyvang.which-key/groups.toml`. See the
[plugin README](https://github.com/CowboyVang/herdr-which-key#your-own-groups).

To move it off `prefix space`, edit the binding in `config/herdr/.config/herdr/config.toml` yourself.
Don't use `which-key bind` or the "change the opening key" action. They rewrite `config.toml` and
drop a `.bak-` copy next to it, and `config.toml` is a stow symlink into this repo.
