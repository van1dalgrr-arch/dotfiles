<div align="center">

# dotfiles

**Мой Mac для Go-бэкенда: ставится одной командой, проверяет себя сам, не тормозит на 8 ГБ.**

[![ci](https://github.com/van1dalgrr-arch/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/van1dalgrr-arch/dotfiles/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/van1dalgrr-arch/dotfiles?style=flat-square&color=a855f7)](https://github.com/van1dalgrr-arch/dotfiles/releases)
[![license](https://img.shields.io/badge/license-MIT-101010?style=flat-square)](LICENSE)

<img src="docs/desktop.jpg" alt="Ghostty и Zed, разложенные AeroSpace" width="100%">

**[Установка](#установка)** · **[Каждый день](#каждый-день)** · **[Что внутри](#что-внутри)** · **[Подробно](docs/details.ru.md)**

🇬🇧 [English version](README.md)

</div>

---

## Коротко

- **Одна команда — и чистый Mac готов:** программы, конфиги, тема, обои. Повторный запуск ничего не ломает.
- **Сам себя проверяет:** `dot doctor` за 2 секунды смотрит всю систему и к каждой проблеме пишет, как её починить.
- **Бережёт память:** Docker на OrbStack, промпт без лишних процессов, ничего тяжёлого в фоне.
- **Код пишет нейросеть — Claude**, решаю и проверяю я. Каждый такой коммит подписан, всё проходит тесты и CI. [Подробнее →](docs/details.ru.md#кто-пишет-код)

## Установка

```bash
curl -fsSL https://raw.githubusercontent.com/van1dalgrr-arch/dotfiles/main/bootstrap.sh | bash
exec zsh
dot doctor          # всё должно быть ✓
```

Берёшь себе — сначала поменяй имя в [`git/.gitconfig`](git/.gitconfig) и лишнее в [`Brewfile`](Brewfile).
Удалить всё: `./uninstall.sh --yes`. [Как это устроено →](docs/how-it-works.ru.md)

## Каждый день

Забыл команду — нажми `?` в терминале.

| Команда | Что делает |
|---|---|
| `p` | перейти в проект из `~/dev` |
| `up` | поднять базу и запустить API проекта |
| `nvim .` | редактор; `пробел` — меню всех действий |
| `пробел r h` → `Enter` | **Postman в nvim:** запрос к API, ответ справа · [инструкция](docs/postman.ru.md) |
| `orbstack` | контейнеры: таблица, логи, перезапуск |
| `gg` | git в удобном интерфейсе (lazygit) |
| `dot doctor` | всё ли в порядке с системой |
| `dot backup` | бэкап незапушенного на GitHub (раз в неделю — напомнит сам) |
| `update` | обновить всё, раз в неделю |
| `theme` · `wall` | сменить тему · обои |

## Что внутри

| | |
|---|---|
| **Терминал** | [Ghostty](ghostty) — строгий, как на Linux: без рамки, вкладки в заголовке, выпадает по `` ctrl+` `` |
| **Окна** | [AeroSpace](aerospace) — раскладывает окна плиткой, всё с клавиатуры |
| **Редакторы** | [Neovim](nvim) с Postman и списком эндпоинтов · [Zed](zed) · [Rune](rune) с клавишами GoLand |
| **Оболочка** | [zsh](zsh) — свой быстрый промпт, подсказки, шпаргалка `?` |
| **Контейнеры** | OrbStack + своя панель [`orbstack`](berth) на Go |
| **Git** | lazygit, красивый diff, защита от утечки паролей в каждом коммите ([git](git)) |
| **Вид** | 4 темы и 33 живых обоев, которые меняются в течение дня ([themes](themes), [docs](docs/wallpapers.ru.md)) |
| **Проверки** | `dot doctor`, `dot project doctor`, тесты установщика, CI на каждый push ([lib](lib), [tests](tests)) |

## Документация

| | |
|---|---|
| [Как пользоваться](docs/guide.ru.md) | все команды по разделам |
| [Горячие клавиши](docs/hotkeys.ru.md) | окна, терминал, редакторы |
| [Postman в nvim](docs/postman.ru.md) | запросы к API за 5 шагов |
| [Если что-то не так](docs/troubleshooting.ru.md) | частые проблемы и решения |
| [Если Mac сбросился](docs/recovery.ru.md) | восстановление, в том числе из `dot backup` |
| [**Всё подробно**](docs/details.ru.md) | полная версия: каждая часть, проверки, версии, безопасность, заметки Claude |

---

<div align="center">

[MIT](LICENSE) — бери что нравится · [журнал изменений](CHANGELOG.md)

</div>
