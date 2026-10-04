# Hotkeys

AeroSpace, Ghostty and Zed shortcuts. In the terminal, `?` (or `ctrl+/`) shows all of them plus every function and alias.

## AeroSpace — windows and workspaces

| Keys | Action |
|---|---|
| `alt-enter` | new terminal |
| `alt-e` | file manager (yazi) |
| `alt-q` | close window |
| `alt-h/j/k/l` | focus left / down / up / right |
| `alt-shift-h/j/k/l` | move window |
| `alt-1…9` | go to workspace |
| `alt-shift-1…9` | send window to workspace |
| `alt-tab` | previous workspace |
| `alt-/` · `alt-,` | layout: tiles · accordion |
| `alt-shift-f` | fullscreen |
| `alt-shift-space` | floating ↔ tiling |
| `alt-r` | resize mode (`hjkl`, `esc`) |

## Ghostty — terminal

| Keys | Action |
|---|---|
| `` ctrl+` `` | drop-down terminal from any app |
| `cmd-d` · `cmd-shift-d` | split right · down |
| `cmd-alt-arrows` | move between splits |
| `cmd-shift-enter` | zoom split |
| `cmd-q` | close windows (Ghostty stays in the background, `` ctrl+` `` keeps working) |
| `cmd-shift-,` | reload config after a theme change |

## Zed — editor

| Keys | Action |
|---|---|
| `ctrl-r` | task menu: `up`, `air`, tests, coverage, linter, compose logs, `curl /health` |
| `ctrl-t` | run the test under the cursor |
| `f5` | debug with Delve: `cmd/api`, current package, or the test under the cursor |
| `ctrl-shift-r` | rerun the last task |
| `alt-g` · `alt-d` | lazygit · lazydocker inside Zed |
| `cmd-j` | terminal |
| `cmd-1` · `cmd-2` · `cmd-3` | files · outline · git |
| `cmd-shift-d` | all project diagnostics |

Go snippets: `iferr`, `iferrw`, `ginh`, `ginbind`, `ginr`, `ginmw`, `ttest`, `htest`, `bench`, `qrow`, `slog`, `jstruct`, `ctxt`.

Also: golangci-lint runs as a language server (warnings right in the code), `.http` files send requests
to your API like REST Client in VS Code, `cmd-alt-l` centers the text.
