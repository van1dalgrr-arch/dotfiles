# bin

🇷🇺 [Русская версия](README.ru.md)

Executables on `PATH`. Here: `dot`, the one command for managing the setup.

| File | What |
|---|---|
| `dot` | entry point: parses the command and calls modules from [lib/](../lib) |
| `rune-ide` | nvim features for Rune: Gin endpoints, `api.http` and sending requests, tasks, Claude review, code screenshots — via the same `nvim/lua/dotfiles` modules ([rune/](../rune)) |
| `rune-go` | helper for Rune's Go commands: main package, lint/vet/build as a jump list, test at cursor ([rune/](../rune)) |

## Commands

| | |
|---|---|
| `dot doctor [--deep] [--json]` | is everything in place (read-only; `--json` for jq and CI) |
| `dot work [name\|off\|list]` | project mode: bring up its containers and editor; `off` shuts everything down to Finder, Happ, Ghostty |
| `dot sync [--yes]` | pull fresh dotfiles: shows what's coming, fast-forward only, then tests and doctor |
| `dot backup [status]` | backup without Time Machine: unpushed work, changes, system snapshot → private `dotfiles-backup` |
| `dot project doctor [dir]` | what a project has and lacks |
| `dot tools [install] [devops]` | pinned Go tools |
| `dot install` · `dot update` | brew bundle + install.sh · weekly upkeep |
| `dot macos [--yes] [group]` | macOS settings (plan without `--yes`) |
| `dot theme` · `dot wall` · `dot check` · `dot edit` | theme · wallpaper · CI checks · open in Zed |

Exit codes: `0` ok (warnings allowed), `1` errors, `2` bad usage. `Tab` completes everything.

[← dotfiles](../README.md)
