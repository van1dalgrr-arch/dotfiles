# Dev Night Theme

🇷🇺 [Русская версия](README.ru.md)

Zed theme extension: **Dev Night** (dark) and **Dev Day** (light), saturated violet and blue accents.

| File | What |
|---|---|
| `themes/dev-night.json` | both themes; Dev Day is generated from Dev Night by `../tools/light.py` |
| `extension.toml` | extension manifest (id `dev-night-theme`) |
| `LICENSE` | MIT, required by the Zed extension registry |

**Installed by `install.sh` as symlinks:**

- `dev-night-theme` → `~/Library/Application Support/Zed/extensions/installed/dev-night-theme`

## Change a color

Edit Dev Night in `themes/dev-night.json`, then `python3 zed/tools/light.py` (Dev Day) and `python3 zed/tools/preview.py` (picture). Zed reloads the theme on its own.

[← dotfiles](../../README.md)
