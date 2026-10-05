# zsh

🇬🇧 [English version](README.md)

Конфиг shell: свой промпт, алиасы, функции. Стартует за ~0.15 с. Все команды — [docs/guide.ru.md](../docs/guide.ru.md).

| Файл | Что это |
|---|---|
| `.zshrc` | PATH, oh-my-zsh, fzf, zoxide, atuin, алиасы, `p`, `pl`, `up`, `gco`, приветствие |
| `prompt.zsh` | промпт в рамке, сворачивание, подсказки «команда не найдена» |
| `theme.zsh` | `theme`, `wall`, `wall add`, `backdrop`, `palette`, светлый режим |
| `reminders.zsh` | напоминания под приветствием: давно не было `update`, незапушенное |
| `backend.zsh` | `db`, `vuln`, `load`, алиасы Kubernetes |
| `gonew.zsh` | `gonew`: новый Go-проект с CI |
| `update.zsh` | `update`: обслуживание |
| `cheatsheet.zsh` | шпаргалка `?` / `ctrl+/` |
| `ram.zsh` | `ram`: память по приложениям |
| `completions/_dot` | дополнение по Tab для `dot`, `theme`, `wall`, `backdrop`, `awake` |

**`install.sh` ставит симлинками:**

- `.zshrc` → `~/.zshrc`

## Порядок загрузки

`.zshrc` подключает oh-my-zsh, потом `theme.zsh` (палитра первой — остальное берёт её цвета), промпт, утилиты и остальные модули. Подсветка синтаксиса — последней.

[← dotfiles](../README.md) · [как пользоваться](../docs/guide.ru.md)
