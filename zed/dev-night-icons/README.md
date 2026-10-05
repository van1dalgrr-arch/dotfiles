# Dev Night Icons

🇷🇺 [Русская версия](README.ru.md)

Zed icon theme extension: the same Nerd Font glyphs as in the terminal, in Dev Night colors.

| File | What |
|---|---|
| `icons/*.svg` | the icons, generated |
| `icon_themes/dev-night-icons.json` | file type → icon mapping |
| `extension.toml` | extension manifest (id `dev-night-icons`) |
| `LICENSE` | MIT |

**Installed by `install.sh` as symlinks:**

- `dev-night-icons` → `~/Library/Application Support/Zed/extensions/installed/dev-night-icons`

## Rebuild

`swift zed/tools/build-icons.swift`.

[← dotfiles](../../README.md)
