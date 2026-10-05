# Dev Night для GoLand

🇬🇧 [English version](README.md)

Dev Night и Dev Day для GoLand и других IDE JetBrains, собранные из Zed-темы.

| Файл | Что это |
|---|---|
| `Dev Night.icls` | цвета кода, тёмная |
| `Dev Day.icls` | цвета кода, светлая |
| `build.py` | генерирует оба `.icls` и jar-плагин (интерфейс + код) в `dist/` |

## Установка

**Плагин:** скачай jar из [релиза](https://github.com/van1dalgrr-arch/dotfiles/releases/tag/jetbrains-v1.0.0) → Settings → Plugins → ⚙️ → Install Plugin from Disk → Appearance → Theme → Dev Night.

**Только цвета кода:** Settings → Editor → Color Scheme → ⚙️ → Import Scheme → `Dev Night.icls`.

Пересобрать: `python3 jetbrains/build.py`.

[← dotfiles](../README.md) · [как пользоваться](../docs/guide.ru.md)
