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

## Using it

| Command | What |
|---|---|
| `git undo` | undo the last commit, changes stay in the files |
| `git amend` | add changes to the last commit without a new message |
| `git wip` / `git unwip` | quickly save everything as a `wip` commit / take it back |
| `git fixup` | a fix for one of the recent commits (pick with fzf); `rebase -i` puts it in place |
| `git recent` | the last 10 branches by date |
| `git gone` / `git tidy` | branches deleted on GitHub after merge / delete them locally (merged only) |

Also on: `pull` rebases (no extra merge commits), `rebase` stashes and restores uncommitted work by itself,
`rerere` remembers how you resolved a conflict and replays it; a new branch sets its upstream on the first `push`.

[← dotfiles](../README.md)
