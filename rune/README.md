# Rune

🇷🇺 [Русская версия](README.ru.md) · [← dotfiles](../README.md)

[Rune](https://rune.build) is a GPU-rendered, keyboard-driven IDE written in Go (Metal on macOS),
with Go as a first-class language and extensions written in Go too. It's the editor I'm moving to
from Zed, gradually: both are set up, Zed stays the default until Rune covers the daily work.

| File | What |
|---|---|
| `config.yaml` | personal config → `~/.rune/config.yaml` (linked by `install.sh`): the **Dev Night** theme (same palette as the Zed theme and the terminal), font 15, `zsh` in the terminal, `:doctor` / `:gotest` / `:lg` aliases |
| `dot-ext/` | **`rune-dot`**, a Rune extension in Go (`rune-go-sdk`): `:work <mode>` / `:work off` run `dot work` with mode completion, `:projectdoctor` runs `dot project doctor` for the file in focus; results come as notifications. Built by `install.sh` into `~/go/bin/rune-dot`; `make check` and CI run its tests |

## No traffic by default

Rune ships with telemetry on, a daily update check and auto-joining its peer network (port 7473).
`config.yaml` turns all three off, so Rune sends nothing on its own: update with `:upgrade`,
join the network with `:network up` when you need it.

## Install

```sh
# DMG from GitHub releases (Apple Silicon): Rune-darwin-arm64.dmg
open https://github.com/unstablebuild/rune/releases/latest
```

On first launch Rune asks for a key preset (pick **standard**, the same keys as Zed/VS Code) and
writes it into `config.yaml`, which is this repo's file through the symlink — review the diff and commit it.
`dot doctor` shows Rune as optional and warns when the `dot` extension isn't built.

## Writing your own extension

`dot-ext/` is a small template: `main.go` only declares metadata and permissions and registers
commands, `handler.go` holds the logic behind SDK interfaces, and `handler_test.go` tests it with fakes.
Try a rebuilt extension without restarting: `extensions restart dot` in the Rune console.
