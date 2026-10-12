# bin

🇷🇺 [Русская версия](README.ru.md)

Executables on `PATH`. Here: `dot`, the one command for managing the setup.

| File | What |
|---|---|
| `dot` | entry point: parses the command and calls modules from [lib/](../lib) |

## Commands

| | |
|---|---|
| `dot doctor [--deep] [--json]` | is everything in place (read-only; `--json` for jq and CI) |
| `dot work [name\|off\|list]` | project mode: bring up its containers and editor; `off` shuts everything down to Finder, Happ, Ghostty |
| `dot sync [--yes]` | pull fresh dotfiles: shows what's coming, fast-forward only, then tests and doctor |
| `dot project doctor [dir]` | what a project has and lacks |
| `dot tools [install] [devops]` | pinned Go tools |
| `dot install` · `dot update` | brew bundle + install.sh · weekly upkeep |
| `dot macos [--yes] [group]` | macOS settings (plan without `--yes`) |
| `dot theme` · `dot wall` · `dot check` · `dot edit` | theme · wallpaper · CI checks · open in Zed |

Exit codes: `0` ok (warnings allowed), `1` errors, `2` bad usage. `Tab` completes everything.

[← dotfiles](../README.md)
