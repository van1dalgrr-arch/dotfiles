# lib

🇷🇺 [Русская версия](README.ru.md)

Modules of the `dot` command. Plain bash 3.2 (the one shipped with macOS), no dependencies.

| File | What |
|---|---|
| `ui.sh` | output: ✓ ! ✗ ○ statuses, colors, summary, helpers |
| `doctor.sh` | `dot doctor`: links, Homebrew and App Store apps, Go, Docker, Kubernetes, IaC, git, Ghostty, Zed, Safari, shell, macOS (security, backups, `macos.sh` drift, `awake`) |
| `snapshot.sh` | `dot snapshot`: system snapshot before a macOS upgrade, `dot snapshot diff` after |
| `project.sh` | `dot project doctor`: Go project checklist |
| `tools.sh` | `dot tools`: pinned Go tools |

## Tests

[tests/smoke.sh](../tests/smoke.sh) (`make test`).

[← dotfiles](../README.md)
