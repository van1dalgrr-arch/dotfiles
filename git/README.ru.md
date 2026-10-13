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

## Как пользоваться

| Команда | Что делает |
|---|---|
| `git undo` | отменить последний коммит, изменения остаются в файлах |
| `git amend` | дописать изменения в последний коммит без нового сообщения |
| `git wip` / `git unwip` | быстро сохранить всё коммитом `wip` / снять его обратно |
| `git fixup` | поправка к одному из последних коммитов (выбор через fzf); при `rebase -i` встанет на место сама |
| `git recent` | последние 10 веток по дате |
| `git gone` / `git tidy` | ветки, удалённые на GitHub после merge / удалить их локально (только слитые) |

Что ещё включено: `pull` делает rebase (без лишних merge-коммитов), `rebase` сам прячет и возвращает незакоммиченное,
`rerere` запоминает, как ты разрешил конфликт, и повторяет это; новая ветка сама настраивает upstream при первом `push`.

[← dotfiles](../README.ru.md) · [как пользоваться](../docs/guide.ru.md)
