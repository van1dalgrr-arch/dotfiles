# Zed

🇷🇺 [Русская версия](README.ru.md)

Config for [Zed](https://zed.dev), the main editor, plus my own themes and icons as Zed extensions.

| File | What |
|---|---|
| `settings.json` | fonts, Dev Night/Dev Day following macOS, LSP settings, auto-installed extensions |
| `keymap.json` | shortcuts (`f5` debug, `ctrl-t` tests…) |
| `tasks.json` | tasks on `ctrl-r`: run, tests, coverage, compose logs |
| `debug.json` | Delve debugger configs |
| `snippets/go.json` | Go snippets |
| `dev-night-theme/` | Zed extension: Dev Night + Dev Day themes |
| `dev-night-icons/` | Zed extension: file icons |
| `tools/` | generators: light theme, preview picture, icons |

**Installed by `install.sh` as symlinks:**

- `settings.json` → `~/.config/zed/settings.json`
- `keymap.json` → `~/.config/zed/keymap.json`
- `tasks.json` → `~/.config/zed/tasks.json`
- `debug.json` → `~/.config/zed/debug.json`
- `snippets/go.json` → `~/.config/zed/snippets/go.json`
- `dev-night-theme` → `~/Library/Application Support/Zed/extensions/installed/dev-night-theme`
- `dev-night-icons` → `~/Library/Application Support/Zed/extensions/installed/dev-night-icons`

## Notes

The two extensions are linked into Zed as dev extensions by `install.sh`. A JetBrains port of the same themes: [jetbrains/](../jetbrains).

[← dotfiles](../README.md)
