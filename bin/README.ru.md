# bin

🇬🇧 [English version](README.md)

Исполняемые файлы в `PATH`. Здесь `dot` — одна команда для управления всей настройкой.

| Файл | Что это |
|---|---|
| `dot` | точка входа: разбирает команду и вызывает модули из [lib/](../lib) |
| `rune-go` | помощник Go-команд Rune: main-пакет, lint/vet/build списком для перехода, тест под курсором ([rune/](../rune)) |

## Команды

| | |
|---|---|
| `dot doctor [--deep] [--json]` | всё ли на месте (только читает; `--json` — для jq и CI) |
| `dot work [имя\|off\|list]` | режим проекта: поднять контейнеры и редактор; `off` гасит всё до Finder, Happ, Ghostty |
| `dot sync [--yes]` | подтянуть свежие dotfiles: показать, что придёт, только fast-forward, потом тесты и doctor |
| `dot backup [status]` | бэкап без Time Machine: незапушенное, правки, снимок системы → приватный `dotfiles-backup` |
| `dot project doctor [папка]` | что есть в проекте и чего не хватает |
| `dot tools [install] [devops]` | Go-утилиты закреплённых версий |
| `dot install` · `dot update` | brew bundle + install.sh · обслуживание |
| `dot macos [--yes] [группа]` | настройки macOS (без `--yes` — план) |
| `dot theme` · `dot wall` · `dot check` · `dot edit` | тема · обои · проверки CI · открыть в Zed |

Коды выхода: `0` ок (предупреждения можно), `1` ошибки, `2` неверный вызов. `Tab` дополняет всё.

[← dotfiles](../README.ru.md) · [как пользоваться](../docs/guide.ru.md)
