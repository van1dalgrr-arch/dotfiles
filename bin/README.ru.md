# bin

🇬🇧 [English version](README.md)

Исполняемые файлы в `PATH`. Здесь `dot` — одна команда для управления всей настройкой.

| Файл | Что это |
|---|---|
| `dot` | точка входа: разбирает команду и вызывает модули из [lib/](../lib) |

## Команды

| | |
|---|---|
| `dot doctor [--deep]` | всё ли на месте (только читает) |
| `dot project doctor [папка]` | что есть в проекте и чего не хватает |
| `dot tools [install] [devops]` | Go-утилиты закреплённых версий |
| `dot install` · `dot update` | brew bundle + install.sh · обслуживание |
| `dot macos [--yes] [группа]` | настройки macOS (без `--yes` — план) |
| `dot theme` · `dot wall` · `dot check` · `dot edit` | тема · обои · проверки CI · открыть в Zed |

Коды выхода: `0` ок (предупреждения можно), `1` ошибки, `2` неверный вызов. `Tab` дополняет всё.

[← dotfiles](../README.md) · [как пользоваться](../docs/guide.ru.md)
