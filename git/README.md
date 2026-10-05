# Git

🇷🇺 [Русская версия](README.ru.md)

Global Git config, hooks and ignore rules.

| File | What |
|---|---|
| `.gitconfig` | identity, delta pager, rebase on pull, rerere, aliases (`undo`, `amend`, `wip`, `fixup`, `recent`, `tidy`) |
| `delta.gitconfig` | diff colors (Rosé Pine reference, recolored by `theme`) |
| `commit-template` | hint shown in the commit editor |
| `ignore` | global .gitignore: `.env`, keys, `.DS_Store` |
| `hooks/` | global hooks (`core.hooksPath`): `pre-commit` runs gitleaks; the rest chain to a repo's own hooks via `_chain` |
| `repo-hooks/pre-push` | this repo only: `make check` + tests before every push |

**Installed by `install.sh` as symlinks:**

- `.gitconfig` → `~/.gitconfig`
- `repo-hooks/pre-push` → `~/dotfiles/.git/hooks/pre-push`

## Secrets

gitleaks blocks a commit that contains a token or a key. A false positive: add `gitleaks:allow` on that line.

[← dotfiles](../README.md)
