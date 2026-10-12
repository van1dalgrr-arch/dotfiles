# Hotkeys

🇷🇺 [Русская версия](hotkeys.ru.md) · [all docs](README.md)

AeroSpace, Ghostty, `orbstack` and Zed. In the terminal, `?` (or `ctrl+/`) shows all of them plus every function and alias.

## AeroSpace — windows and workspaces

Hotkeys work on any keyboard layout, Russian included.

| Keys | Action |
|---|---|
| `alt-enter` | new terminal |
| `alt-e` | file manager (yazi) |
| `alt-q` | close window |
| `alt-h/j/k/l` | focus left / down / up / right |
| `alt-shift-h/j/k/l` | move window |
| `alt-1…9` | go to workspace |
| `alt-shift-1…9` | send window to workspace (and follow it) |
| `alt-tab` | previous workspace |
| `alt-shift-tab` | move the workspace to the next monitor |
| `alt-/` · `alt-,` | layout: tiles · accordion |
| `alt-shift-f` | fullscreen |
| `alt-shift-space` | floating ↔ tiling |
| `alt-minus` · `alt-equal` | narrower · wider |
| `alt-r` | resize mode: `hjkl`, `enter`/`esc` to leave |
| `alt-shift-;` | service mode: `r` flatten the layout, `f` floating, `backspace` close all but this one, `esc` reload |
| `alt-shift-c` | reload the config |

Workspaces: 2 — code, 3 — browser, 4 — chats, 5 — music; the terminal stays where you open it.

## Ghostty — terminal

| Keys | Action |
|---|---|
| `` ctrl+` `` | drop-down terminal from any app |
| `cmd-d` · `cmd-shift-d` | split right · down |
| `cmd-alt-arrows` | move between splits |
| `cmd-shift-enter` | zoom split |
| `cmd-shift-e` | equalize splits |
| `cmd-q` | close windows (Ghostty stays in the background, `` ctrl+` `` keeps working) |
| `cmd-shift-,` | reload the config (rarely needed: `theme`, `wall`, `backdrop` reload it themselves) |

## `orbstack` — containers

| Keys | Action |
|---|---|
| `↑↓` `j k` · wheel · click | pick a container (click again for actions) |
| `g` · `G` | first · last |
| `enter` | actions, each explained, with the docker command |
| `l` · `s` | follow logs · shell inside |
| `r` · `x` · `d` | restart · stop/start · remove |
| `i` · `f` · `c` | inside · Dockerfile · compose file |
| `n` · `t` · `w` | new from a template · live stats · live rebuild |
| `u` · `U` | compose up · down (the project in this folder) |
| `e` · `E` | start · stop the engine |
| `?` · `q` | all keys · quit |

In the viewer (`i`, `f`, `c`): `↑↓` scroll, `g`/`G` top/bottom, `esc` back.

## Zed — editor

| Keys | Action |
|---|---|
| `ctrl-r` | task menu: `up`, `air`, tests (also with `-race`), coverage, linter, govulncheck, migrations, sqlc, compose logs, `curl /health` |
| `ctrl-t` | run the test under the cursor |
| `f5` | debug with Delve: `cmd/api`, current package, the test under the cursor, or attach to `dlv` in a container |
| `ctrl-shift-r` | rerun the last task |
| `alt-g` · `alt-d` | lazygit · lazydocker inside Zed |
| `cmd-j` | terminal |
| `cmd-1` · `cmd-2` · `cmd-3` | files · outline · git |
| `cmd-0` · `cmd-9` | left · right dock |
| `cmd-shift-d` | all project diagnostics |
| `cmd-shift-b` · `cmd-alt-b` | git blame · inline blame |
| `alt-up` · `alt-down` | move the line up · down |
| `cmd-alt-l` | center the text |

Go snippets: `iferr`, `iferrw`, `ginh`, `ginbind`, `ginr`, `ginmw`, `ttest`, `htest`, `bench`, `qrow`, `slog`, `jstruct`, `ctxt`.
SQL: `mtable`, `mdrop`, `mcol`, `mindex`, `mfk`, `mtouch` (migrations), `qone`, `qmany`, `qins`, `qexec` (sqlc).
Dockerfile: `dgo` (cached build, distroless), `ddlv` (under Delve). Compose/k8s: `cpg`, `credis`, `cdep`, `cwatch`, `kprobe`.

Also: golangci-lint runs as a language server (warnings right in the code), and `.http` files send requests
to your API like REST Client in VS Code.
