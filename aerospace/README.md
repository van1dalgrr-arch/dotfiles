# AeroSpace

🇷🇺 [Русская версия](README.ru.md)

Config for [AeroSpace](https://github.com/nikitabobko/AeroSpace), the i3-style tiling window manager. Hotkeys work on any keyboard layout.

| File | What |
|---|---|
| `aerospace.toml` | workspaces, hotkeys (`alt-…`), app rules: Zed → workspace 2, Safari → 3, Ghostty floats |

**Installed by `install.sh` as symlinks:**

- `aerospace.toml` → `~/.config/aerospace/aerospace.toml`

## Notes

AeroSpace starts at login and launches Ghostty in the background, which keeps the quick terminal (`` ctrl+` ``) available. Ghostty windows float on the current workspace: tiling them broke the quick terminal. It also catches `` ctrl+` `` and runs `ghostty/quick-terminal.applescript` to toggle Ghostty's quick terminal. Apply changes: `alt-shift-c`. Hotkey list: [docs/hotkeys.md](../docs/hotkeys.md).

## Using it

- **Windows tile themselves**; `alt-h/j/k/l` — focus, `alt-shift-h/j/k/l` — move, `alt-1…9` — workspace.
- **Layout:** `alt-/` — tiles, `alt-,` — accordion, `alt-shift-f` — fullscreen, `alt-shift-space` — floating ↔ tiling.
- **Size:** `alt--` / `alt-=` or the `alt-r` mode (then `h/j/k/l`, `esc` to leave).
- **Mind the other apps:** the whole `alt` (and `alt-shift`) layer belongs to AeroSpace, so apps never see it.
  Put your editor hotkeys on `cmd`, `ctrl-alt` or F-keys — that's what Rune does.

[← dotfiles](../README.md)
