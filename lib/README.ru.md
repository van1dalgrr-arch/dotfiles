# lib

🇬🇧 [English version](README.md)

Модули команды `dot`. Чистый bash 3.2 (тот, что в macOS из коробки), без зависимостей.

| Файл | Что это |
|---|---|
| `ui.sh` | вывод: статусы ✓ ! ✗ ○, цвета, итог, утилиты |
| `doctor.sh` | `dot doctor`: ссылки, Homebrew и App Store, Go, Docker, Kubernetes, IaC, git, Ghostty, Zed, Rune, Safari, shell, macOS (защита, бэкапы, откат настроек `macos.sh`, `awake`) |
| `snapshot.sh` | `dot snapshot`: снимок системы перед обновлением macOS, `dot snapshot diff` — после |
| `project.sh` | `dot project doctor`: чеклист Go-проекта |
| `tools.sh` | `dot tools`: Go-утилиты закреплённых версий |
| `sync.sh` | `dot sync`: подтянуть свежие dotfiles — только fast-forward, потом тесты и `dot doctor` |
| `work.sh` | `dot work`: режимы проектов из [work/](../work) — поднять контейнеры и редактор, `work off` гасит всё |

## Тесты

[tests/smoke.sh](../tests/smoke.sh) (`make test`).

## Правила для модулей

- **bash 3.2** — тот, что стоит в macOS до Homebrew: без ассоциативных массивов, `mapfile` и `${var,,}`.
- **Только читают**, если команда не просит иного: `doctor` и `project doctor` ничего не меняют.
- **К каждой проблеме — команда, которая её чинит**, через `warning "что" "→ как"`.
- Коды выхода одинаковые: `0` ок, `1` ошибки, `2` неверный вызов.

[← dotfiles](../README.ru.md) · [как пользоваться](../docs/guide.ru.md)
