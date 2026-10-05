# Git

🇬🇧 [English version](README.md)

Глобальный конфиг Git, хуки и игнор.

| Файл | Что это |
|---|---|
| `.gitconfig` | имя, delta, rebase при pull, rerere, алиасы (`undo`, `amend`, `wip`, `fixup`, `recent`, `tidy`) |
| `delta.gitconfig` | цвета diff (эталон Rosé Pine, перекрашивает `theme`) |
| `commit-template` | подсказка в редакторе коммита |
| `ignore` | глобальный .gitignore: `.env`, ключи, `.DS_Store` |
| `hooks/` | глобальные хуки (`core.hooksPath`): `pre-commit` — gitleaks, остальные через `_chain` вызывают хуки самого репозитория |
| `repo-hooks/pre-push` | только для dotfiles: `make check` и тесты перед каждым push |

**`install.sh` ставит симлинками:**

- `.gitconfig` → `~/.gitconfig`
- `repo-hooks/pre-push` → `~/dotfiles/.git/hooks/pre-push`

## Секреты

gitleaks не пропустит коммит с токеном или ключом. Ложная тревога — допиши в строку `gitleaks:allow`.

[← dotfiles](../README.md) · [как пользоваться](../docs/guide.ru.md)
