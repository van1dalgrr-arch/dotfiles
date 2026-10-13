# Ghostty

🇷🇺 [Русская версия](README.ru.md)

Config for the [Ghostty](https://ghostty.org) terminal: a plain Linux-style look — no frame buttons or shadow, tabs right in the titlebar, a flat background, block cursor, tight padding; quick terminal on `` ctrl+` ``, smooth cursor. A backdrop from the wallpaper is opt-in: `backdrop`.

| File | What |
|---|---|
| `config.ghostty` | font, padding, splits, quick terminal, shaders, keys; includes the generated theme and backdrop |
| `fx.sh` | effects switcher behind `fx`: writes `~/.config/ghostty/fx.ghostty` |
| `shaders/cursor_smooth.glsl` | `cursor`: smooth cursor — the real one is hidden, this shader draws and glides it |
| `shaders/cursor_trail.glsl` | `trail`: glowing trail on big cursor jumps |
| `shaders/sparks.glsl` | `sparks`: a few sparks fly out of the cursor as you type |
| `shaders/focus.glsl` | `focus`: the window that gets focus flashes along its edges — handy with AeroSpace |
| `shaders/glow.glsl` | `glow`: soft neon halo around bright text (off in light mode) |
| `shaders/.prefix.glsl` | Ghostty's shader header, only for `make check` to compile the shaders |
| `quick-terminal.sh` | what AeroSpace runs on `` ctrl+` ``: builds the activation helper once, then runs the AppleScript |
| `activate.swift` | activates Ghostty without raising all its windows, so only the quick terminal comes forward |
| `quick-terminal.applescript` | toggles the quick terminal; called by AeroSpace on `` ctrl+` `` |

**Installed by `install.sh` as symlinks:**

- `config.ghostty` → `~/.config/ghostty/config.ghostty`

## Generated, not in git

`theme` writes `~/.config/ghostty/theme.ghostty` and two themes (`dotfiles-dark`, `dotfiles-light`): Ghostty follows macOS dark/light mode. `backdrop` writes `~/.config/ghostty/backdrop.ghostty`. After `theme`, `wall`, `backdrop` and `update` Ghostty reloads by itself (AppleScript `reload_config`); after editing the config by hand: `cmd+shift+,`.

## Effects: `fx`

`fx` (fzf: Tab to mark, Enter toggles) or `fx on sparks`, `fx off trail`, `fx set none`. Default: `cursor trail`.
Shaders take their colors from the terminal theme (`iCursorColor`, `iPalette`), so `theme` and light mode recolor them live. They're used straight from the repo, nothing is copied.

## Quick terminal

`` ctrl+` `` is caught by AeroSpace (it already has Accessibility), which runs `quick-terminal.sh` to toggle Ghostty's quick terminal. So it works from any app and Ghostty needs no extra permission.

[← dotfiles](../README.md)
