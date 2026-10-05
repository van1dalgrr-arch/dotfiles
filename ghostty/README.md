# Ghostty

🇷🇺 [Русская версия](README.ru.md)

Config for the [Ghostty](https://ghostty.org) terminal: no titlebar, quick terminal on `` ctrl+` ``, smooth cursor, backdrop from the wallpaper.

| File | What |
|---|---|
| `config.ghostty` | font, padding, splits, quick terminal, shaders, keys; includes the generated theme and backdrop |
| `shaders/cursor_smooth.glsl` | smooth cursor: the real one is hidden, this shader draws and glides it |
| `shaders/cursor_trail.glsl` | glowing trail on big cursor jumps; colors recolored by `theme` |
| `shaders/.prefix.glsl` | Ghostty's shader header, only for `make check` to compile the shaders |
| `quick-terminal.applescript` | toggles the quick terminal; called by AeroSpace on `` ctrl+` `` |
| `config.ghostty.pre-clean` | old backup, not used |

**Installed by `install.sh` as symlinks:**

- `config.ghostty` → `~/.config/ghostty/config.ghostty`
- `shaders/cursor_smooth.glsl` → `~/.config/ghostty/shaders/cursor_smooth.glsl`

## Generated, not in git

`theme` writes `~/.config/ghostty/theme.ghostty` and two themes (`dotfiles-dark`, `dotfiles-light`): Ghostty follows macOS dark/light mode. `backdrop` writes `~/.config/ghostty/backdrop.ghostty`. Reload after changes: `cmd+shift+,`.

## Quick terminal

`` ctrl+` `` is caught by AeroSpace (it already has Accessibility), which runs `quick-terminal.applescript` to toggle Ghostty's quick terminal. So it works from any app and Ghostty needs no extra permission.

[← dotfiles](../README.md)
