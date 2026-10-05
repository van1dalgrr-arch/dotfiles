# AeroSpace

🇷🇺 [Русская версия](README.ru.md)

Config for [AeroSpace](https://github.com/nikitabobko/AeroSpace), the i3-style tiling window manager. Hotkeys work on any keyboard layout.

| File | What |
|---|---|
| `aerospace.toml` | workspaces, hotkeys (`alt-…`), app rules: Zed → workspace 2, Safari → 3, Ghostty floats |
| `aerospace.toml.pre-clean` | old backup from before the cleanup, not used |

**Installed by `install.sh` as symlinks:**

- `aerospace.toml` → `~/.config/aerospace/aerospace.toml`

## Notes

AeroSpace starts at login and launches Ghostty in the background, which keeps the quick terminal (`` ctrl+` ``) available. Ghostty windows float on the current workspace: tiling them broke the quick terminal. It also catches `` ctrl+` `` and runs `ghostty/quick-terminal.applescript` to toggle Ghostty's quick terminal. Apply changes: `alt-shift-c`. Hotkey list: [docs/hotkeys.md](../docs/hotkeys.md).

[← dotfiles](../README.md)
