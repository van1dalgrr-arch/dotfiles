# Rune

🇷🇺 [Русская версия](README.ru.md) · [← dotfiles](../README.md)

[Rune](https://rune.build) is a GPU-rendered, keyboard-driven IDE written in Go (Metal on macOS),
with Go as a first-class language and extensions written in Go too. It's the editor I'm moving to
from Zed, gradually: both are set up, Zed stays the default until Rune covers the daily work.

| File | What |
|---|---|
| `config.yaml` | personal config → `~/.rune/config.yaml` (linked by `install.sh`): the **Neon Noir** theme (Dev Night via `:guitheme dev-night`), a **GoLand** keymap, run/test/debug/lint on one key |
| [`../bin/rune-go`](../bin/rune-go) | helper for the Go commands: finds the module and main package from the focused file, prints lint/vet/build errors as `path:line:col` for the jump list |
| `dot-ext/` | **`rune-dot`**, a Rune extension in Go (`rune-go-sdk`): `:work <mode>` / `:work off` run `dot work` with mode completion, `:projectdoctor` runs `dot project doctor` for the file in focus; results come as notifications. Built by `install.sh` into `~/go/bin/rune-dot`; `make check` and CI run its tests |

## Keys — like GoLand

On top of the **standard** preset. AeroSpace owns `alt-h/j/k/l`, `alt-r`, `alt-1…9` and `alt-shift-…`,
so everything here is on `cmd`, `ctrl-alt`, `cmd-alt` and F-keys (F-keys need `fn` on this Mac).
All commands: `cmd-shift-p`; Rune's cheatsheet: `ctrl-cmd-/` (`cmd-/` comments the line, as in GoLand).

The editor handles its own keys **before** commands, so a binding on a key the editor already uses
silently does nothing: `cmd-[`/`]` indent, `ctrl-T` transposes letters, `ctrl-enter` opens a line,
`cmd-J/K/L`, `shift-tab`, `ctrl-alt-↑/↓/H/V`, `cmd-alt-[/]/V`. Those GoLand keys moved to the free
`ctrl-alt` / `ctrl-cmd` layers below.

| | Key | What |
|---|---|---|
| **Navigate** | `cmd-B` · `cmd-alt-B` · `cmd-shift-B` | definition · implementations (type ↔ interface) · type |
| | `alt-F7` / `ctrl-cmd-U` · `F1` / `ctrl-J` | usages · docs |
| | `cmd-O` · `cmd-shift-O` · `cmd-alt-O` · `cmd-E` | type · file · function across the project · open tabs |
| | `cmd-shift-F` · `ctrl-alt-F` · `cmd-F12` | text across the project · git grep · file structure |
| | `cmd-shift-T` · `cmd-alt-←` / `→` | test ↔ code · back / forward |
| | `F2` / `shift-F2` · `alt-shift-E` | next / previous problem · all problems in the file |
| **Refactor** | `shift-F6` · `ctrl-alt-O` · `cmd-.` | rename · imports · every safe fix |
| | `ctrl-shift-T` | every gopls refactoring in a list (25 of them) |
| | `cmd-alt-M` · `cmd-alt-shift-V` · `cmd-alt-C` · `cmd-alt-N` | extract function · variable · constant · inline |
| | `cmd-alt-S` · `cmd-alt-T` | fill struct · json tags |
| | `cmd-alt-I` | **implement an interface**: cursor on the type, `tab` lists the module's and common stdlib interfaces; stubs go to the screen and the clipboard |
| **Generate** | `cmd-shift-N` | **scratch file**: a Go module with `main` (`ctrl-alt-R` runs it); `:scratches` lists them |
| | `cmd-alt-shift-C` · `:github` | copy reference `path:line` from the project root · open the line on GitHub |
| **Run** | `ctrl-alt-R` | `go run` the main package in a task tab (`ctrl-R` there restarts) |
| | `ctrl-shift-R` · `ctrl-alt-T` | test at cursor · all tests (rerun on save) |
| | `ctrl-alt-W` | vet + tests in the background: green/red squares at the edges |
| | `ctrl-alt-L` · `ctrl-alt-E` | golangci-lint · build errors — a jump list with preview |
| **Debug** | `cmd-F8` / `ctrl-alt-B` | breakpoint (set before starting) |
| | `ctrl-alt-D` · `ctrl-shift-D` | debug the main package · the test at cursor |
| | `F8` · `F7` · `shift-F8` · `cmd-alt-R` · `cmd-F2` | step · into · out · resume · stop |
| | `ctrl-alt-N` · `I` · `U` | step (Next) · Into · out (Up) without F-keys |
| | `alt-F8` | evaluate an expression |
| **Git** | `ctrl-alt-G` · `ctrl-alt-Y` · `ctrl-alt-A` | lazygit · file history · line history |
| | `ctrl-cmd-I` / `ctrl-cmd-K` | previous / next change |
| **Tabs** | `cmd-shift-[` / `]` · `ctrl-1…9` | neighbour tab · tab by number |
| | `alt-W` · `cmd-alt-W` · `cmd-shift-W` | close the tab · all but this one · all |
| | `ctrl-alt-[` / `]` | move the tab left / right |
| | `cmd-shift-E` | show / hide the file tree |
| **Windows** | `ctrl-cmd-arrows` · `+shift` | focus a split · move it |

More commands without keys: `:todo`, `:conflicts`, `:changed`, `:gocover` (coverage in the browser), `:gowatchoff`,
`:govet`, `go tidy`, `go vulncheck`, `go add-test`, `go assembly`.

## Like nvim — one key press

Same keys as in [nvim](../nvim/README.md), with regular (non-vim) editing. The logic is shared:
[`bin/rune-ide`](../bin/rune-ide) calls the same `nvim/lua/dotfiles` modules.

| Key | What | Command |
|---|---|---|
| `alt-O` | containers (orbstack) | `:containers` |
| `alt-G` | lazygit (signature help moved to `ctrl-alt-P`) | `:lg` |
| `alt-P` · `ctrl-alt-enter` | **Postman in a file**: the project's `api.http` (generated from Gin routes) · send the request under the cursor | `:postman` · `:httpsend` |
| `alt-A` | **Gin endpoints** with full paths, `enter` jumps to the handler | `:endpoints` |
| `alt-D` | project database (`db`) | `:db` |
| `alt-T` | **tasks** as in nvim: `up`, `air`, tests, coverage, benchmarks, lint, compose, docker build, hadolint, trivy… (`tab` lists them) | `:task <name>` |
| `alt-C` · `ctrl-alt-C` | Claude Code in a tab · **branch review** by Claude as a jump list | `:claude` · `:review` |
| `ctrl-alt-S` | screenshot of the function under the cursor (freeze) → clipboard and `~/Pictures/code` | `:shot` |

Also without keys: `:gw` (PRs and CI), `:ld` (lazydocker), `:yazi`, `:k8s` (k9s), `:backup`.
Go to definition and docs, formerly on `alt-D` / `alt-T`, stay on `cmd-B` and `F1` / `ctrl-J`.

## Go from any workspace

Tasks (`ctrl-alt-T`, `ctrl-alt-W`) run from the module root of the focused file through
`rune-go in`, not from the workspace, so they work when Rune is opened on `~`. `rune-go` and
`rune-ide` also drop Rune's `GOROOT` while its Go package is not installed — otherwise every `go`
fails with `cannot find GOROOT`.
If the packages are gone (say, `~/.rune` was recreated), `dot doctor` says so; install them in
Rune's console (`alt-shift-enter`): `pkg install go`, `pkg install fuzzy-search`.

## No traffic by default

Rune ships with telemetry on, a daily update check and auto-joining its peer network (port 7473).
`config.yaml` turns all three off, so Rune sends nothing on its own: update with `:upgrade`,
join the network with `:network up` when you need it.

## Install

```sh
brew install unstablebuild/tap/rune     # also in the Brewfile
```

On first launch Rune asks for a key preset (pick **standard**, the same keys as Zed/VS Code) and
writes it into `config.yaml`, which is this repo's file through the symlink — review the diff and commit it. Rune rewrites the whole file when it merges in its packages' blocks (`go`, `fuzzy-search`) or saves `:config`, which turns the symlink into a plain file. So the repo keeps the config already in Rune's format with the package blocks in it: nothing left to merge, and the link survives. If it still breaks, `dot doctor` warns and shows how to fold it back.
`dot doctor` shows Rune as optional and warns when the `dot` extension isn't built.

## Writing your own extension

`dot-ext/` is a small template: `main.go` only declares metadata and permissions and registers
commands, `handler.go` holds the logic behind SDK interfaces, and `handler_test.go` tests it with fakes.
Try a rebuilt extension without restarting: `extensions restart dot` in the Rune console.
