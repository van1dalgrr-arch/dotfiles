# atuin

🇷🇺 [Русская версия](README.ru.md)

Config for [atuin](https://atuin.sh), shell history in SQLite: `ctrl+r` opens search with the folder, exit code and duration of every command.

| File | What |
|---|---|
| `config.toml` | compact style, preview, `↑` searches only the current folder, no update checks |

**Installed by `install.sh` as symlinks:**

- `config.toml` → `~/.config/atuin/config.toml`

## Notes

History stays on this Mac (sync is off). Atuin AI is disabled on purpose (`--disable-ai` in `.zshrc`), so `?` keeps opening the cheatsheet.

[← dotfiles](../README.md)
