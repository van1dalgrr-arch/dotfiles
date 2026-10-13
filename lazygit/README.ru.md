# lazygit

🇬🇧 [English version](README.md)

Конфиг [lazygit](https://github.com/jesseduffield/lazygit) — git в интерфейсе терминала (`gg`).

| Файл | Что это |
|---|---|
| `config.yml` | цвета (перекрашивает `theme`), delta для diff |

**`install.sh` ставит симлинками:**

- `config.yml` → `~/Library/Application Support/lazygit/config.yml`

## Как пользоваться

`gg` в папке репозитория (или `ctrl-alt-G` в Rune, `пробел g g` в Neovim). `пробел` — добавить файл,
`c` — коммит, `P` — push, `p` — pull, `enter` — зайти внутрь, `?` — все клавиши.
Иконки файлов и скруглённые рамки включены, diff показывает delta — как в `git diff`.

[← dotfiles](../README.ru.md) · [как пользоваться](../docs/guide.ru.md)
