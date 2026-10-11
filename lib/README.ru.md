# lib

🇬🇧 [English version](README.md)

Модули команды `dot`. Чистый bash 3.2 (тот, что в macOS из коробки), без зависимостей.

| Файл | Что это |
|---|---|
| `ui.sh` | вывод: статусы ✓ ! ✗ ○, цвета, итог, утилиты |
| `doctor.sh` | `dot doctor`: ссылки, Homebrew и App Store, Go, Docker, Kubernetes, IaC, git, Ghostty, Zed, Safari, shell, macOS (защита, бэкапы, откат настроек `macos.sh`, `awake`) |
| `snapshot.sh` | `dot snapshot`: снимок системы перед обновлением macOS, `dot snapshot diff` — после |
| `project.sh` | `dot project doctor`: чеклист Go-проекта |
| `tools.sh` | `dot tools`: Go-утилиты закреплённых версий |

## Тесты

[tests/smoke.sh](../tests/smoke.sh) (`make test`).

[← dotfiles](../README.md) · [как пользоваться](../docs/guide.ru.md)
