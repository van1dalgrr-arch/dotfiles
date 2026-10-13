# VS Code

🇬🇧 [English version](README.md)

Настройки VS Code — запасного редактора (основной — Zed).

| Файл | Что это |
|---|---|
| `settings.json` | настройки и тема |
| `keybindings.json` | горячие клавиши |
| `extensions.txt` | расширения, которые ставит `install.sh` |

**`install.sh` ставит симлинками:**

- `settings.json` → `~/Library/Application Support/Code/User/settings.json`
- `keybindings.json` → `~/Library/Application Support/Code/User/keybindings.json`

## Когда он нужен

Почти никогда: на 8 ГБ VS Code тяжелее Zed в разы. Он остаётся на случай, когда нужно расширение, которого нет
нигде больше. Настройки держатся в той же тёмной гамме, чтобы переход не резал глаз.

[← dotfiles](../README.ru.md) · [как пользоваться](../docs/guide.ru.md)
