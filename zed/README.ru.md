# Zed

🇬🇧 [English version](README.md)

Конфиг [Zed](https://zed.dev) — основного редактора, плюс свои темы и иконки в виде расширений Zed.

| Файл | Что это |
|---|---|
| `settings.json` | шрифты, Dev Night/Dev Day вместе с macOS, настройки LSP, расширения ставятся сами |
| `keymap.json` | хоткеи (`f5` отладка, `ctrl-t` тесты…) |
| `tasks.json` | задачи по `ctrl-r`: запуск, тесты, покрытие, логи compose |
| `debug.json` | конфиги отладчика Delve |
| `snippets/go.json` | сниппеты Go |
| `dev-night-theme/` | расширение Zed: темы Dev Night + Dev Day |
| `dev-night-icons/` | расширение Zed: иконки файлов |
| `tools/` | генераторы: светлая тема, картинка-превью, иконки |

**`install.sh` ставит симлинками:**

- `settings.json` → `~/.config/zed/settings.json`
- `keymap.json` → `~/.config/zed/keymap.json`
- `tasks.json` → `~/.config/zed/tasks.json`
- `debug.json` → `~/.config/zed/debug.json`
- `snippets/go.json` → `~/.config/zed/snippets/go.json`
- `dev-night-theme` → `~/Library/Application Support/Zed/extensions/installed/dev-night-theme`
- `dev-night-icons` → `~/Library/Application Support/Zed/extensions/installed/dev-night-icons`

## Заметки

Оба расширения подключаются в Zed как dev-расширения через `install.sh`. Те же темы для JetBrains — [jetbrains/](../jetbrains).

[← dotfiles](../README.md) · [как пользоваться](../docs/guide.ru.md)
