# Иконки Dev Night

🇬🇧 [English version](README.md)

Расширение Zed с иконками файлов: те же значки Nerd Font, что в терминале, в цветах Dev Night.

| Файл | Что это |
|---|---|
| `icons/*.svg` | иконки, сгенерированные |
| `icon_themes/dev-night-icons.json` | соответствие типов файлов иконкам |
| `extension.toml` | манифест расширения (id `dev-night-icons`) |
| `LICENSE` | MIT |

**`install.sh` ставит симлинками:**

- `dev-night-icons` → `~/Library/Application Support/Zed/extensions/installed/dev-night-icons`

## Пересобрать

`swift zed/tools/build-icons.swift`.

[← dotfiles](../../README.md) · [как пользоваться](../../docs/guide.ru.md)
