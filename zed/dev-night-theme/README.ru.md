# Тема Dev Night

🇬🇧 [English version](README.md)

Расширение-тема для Zed: **Dev Night** (тёмная) и **Dev Day** (светлая), насыщенные фиолетовые и синие акценты.

| Файл | Что это |
|---|---|
| `themes/dev-night.json` | обе темы; Dev Day собирается из Dev Night через `../tools/light.py` |
| `extension.toml` | манифест расширения (id `dev-night-theme`) |
| `LICENSE` | MIT, требование каталога расширений Zed |

**`install.sh` ставит симлинками:**

- `dev-night-theme` → `~/Library/Application Support/Zed/extensions/installed/dev-night-theme`

## Поменять цвет

Правь Dev Night в `themes/dev-night.json`, потом `python3 zed/tools/light.py` (Dev Day) и `python3 zed/tools/preview.py` (картинка). Zed перечитает тему сам.

[← dotfiles](../../README.md) · [как пользоваться](../../docs/guide.ru.md)
