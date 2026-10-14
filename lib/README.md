# lib

🇷🇺 [Русская версия](README.ru.md)

Modules of the `dot` command. Plain bash 3.2 (the one shipped with macOS), no dependencies.

| File | What |
|---|---|
| `ui.sh` | output: ✓ ! ✗ ○ statuses, colors, summary, helpers |
| `doctor.sh` | `dot doctor`: links, Homebrew and App Store apps, Go, Docker, Kubernetes, IaC, git, Ghostty, Zed, Rune, Safari, shell, macOS (security, backups, `macos.sh` drift, `awake`) |
| `snapshot.sh` | `dot snapshot`: system snapshot before a macOS upgrade, `dot snapshot diff` after |
| `project.sh` | `dot project doctor`: Go project checklist |
| `tools.sh` | `dot tools`: pinned Go tools |
| `sync.sh` | `dot sync`: pull fresh dotfiles — fast-forward only, then tests and `dot doctor` |
| `backup.sh` | `dot backup`: unpushed commits (git bundle), uncommitted changes, system snapshot → a private repo |
| `work.sh` | `dot work`: project modes from [work/](../work) — start containers and the editor, `work off` stops everything |

## Tests

[tests/smoke.sh](../tests/smoke.sh) (`make test`).

## Rules for modules

- **bash 3.2** — what macOS ships before Homebrew: no associative arrays, `mapfile` or `${var,,}`.
- **Read-only** unless the command says otherwise: `doctor` and `project doctor` change nothing.
- **Every problem comes with the command that fixes it**, via `warning "what" "→ how"`.
- Same exit codes everywhere: `0` ok, `1` errors, `2` bad usage.

[← dotfiles](../README.md)
