# Zed

🇷🇺 [Русская версия](README.ru.md)

Config for [Zed](https://zed.dev), the main editor, plus my own themes and icons as Zed extensions.

| File | What |
|---|---|
| `settings.json` | fonts, Dev Night/Dev Day following macOS, LSP settings, auto-installed extensions |
| `keymap.json` | shortcuts (`f5` debug, `ctrl-t` tests…) |
| `tasks.json` | tasks on `ctrl-r`: run, tests, coverage, compose logs |
| `debug.json` | Delve debugger configs |
| `snippets/go.json` | Go snippets |
| `dev-night-theme/` | Zed extension: Dev Night + Dev Day themes |
| `dev-night-icons/` | Zed extension: file icons |
| `tools/` | generators: light theme, preview picture, icons |

**Installed by `install.sh` as symlinks:**

- `settings.json` → `~/.config/zed/settings.json`
- `keymap.json` → `~/.config/zed/keymap.json`
- `tasks.json` → `~/.config/zed/tasks.json`
- `debug.json` → `~/.config/zed/debug.json`
- `snippets/go.json` → `~/.config/zed/snippets/go.json`
- `dev-night-theme` → `~/Library/Application Support/Zed/extensions/installed/dev-night-theme`
- `dev-night-icons` → `~/Library/Application Support/Zed/extensions/installed/dev-night-icons`

## Notes

The two extensions are linked into Zed as dev extensions by `install.sh`. A JetBrains port of the same themes: [jetbrains/](../jetbrains).

## Keys and tasks

| Keys | What |
|---|---|
| `ctrl-r` · `ctrl-shift-r` | task list · rerun the last one |
| `ctrl-t` | test at cursor |
| `f5` | debugging (Delve, configs in `debug.json`) |
| `cmd-1` · `cmd-2` · `cmd-3` · `cmd-j` | files · file outline · git · terminal |
| `cmd-shift-d` | every problem in the project |
| `cmd-shift-b` · `cmd-alt-b` | git blame for the file · inline blame |
| `alt-g` · `alt-d` | lazygit · lazydocker right in Zed |

Tasks (`ctrl-r`): `up` (compose dependencies plus the app), air, `go run`, tests for the project / package / at cursor,
benchmark, coverage, golangci-lint, `go mod tidy`, govulncheck, compose up/down/ps/config/logs, image build,
hadolint for the Dockerfile, trivy for the image, `curl /health`, `dot project doctor`, `dot work`.

[← dotfiles](../README.md)
