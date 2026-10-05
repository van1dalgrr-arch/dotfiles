# fastfetch

🇬🇧 [English version](README.md)

Конфиги [fastfetch](https://github.com/fastfetch-cli/fastfetch) — сводка о системе.

| Файл | Что это |
|---|---|
| `greeting.jsonc` | лёгкое приветствие в новом окне Ghostty: логотип macOS, время работы, память (~35 мс) |
| `config.jsonc` | полная версия для `ff` / `neofetch` |

**`install.sh` ставит симлинками:**

- `config.jsonc` → `~/.config/fastfetch/config.jsonc`

## Заметки

Память считается как в `ram` (через `memory_pressure`): кэш macOS не считается занятым. Напоминания под приветствием — в [zsh/reminders.zsh](../zsh/reminders.zsh).

[← dotfiles](../README.md) · [как пользоваться](../docs/guide.ru.md)
