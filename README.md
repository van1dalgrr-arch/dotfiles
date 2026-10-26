<div align="center">

# dotfiles

**My Mac for Go backend work: one command to set up, checks itself, stays fast on 8 GB.**

[![ci](https://github.com/van1dalgrr-arch/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/van1dalgrr-arch/dotfiles/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/van1dalgrr-arch/dotfiles?style=flat-square&color=a855f7)](https://github.com/van1dalgrr-arch/dotfiles/releases)
[![license](https://img.shields.io/badge/license-MIT-101010?style=flat-square)](LICENSE)

<img src="docs/desktop.jpg" alt="Ghostty with two splits: the ghost greeting and git log on the left, Neovim with the Gin endpoints list on the right" width="100%">

<sub>A real screenshot: Ghostty, the terminal on the left, Neovim on the right — <code>space r e</code> lists every endpoint of the project.</sub>

**[Install](#install)** · **[Every day](#every-day)** · **[What's inside](#whats-inside)** · **[Full story](docs/details.md)**

🇷🇺 [Русская версия](README.ru.md)

</div>

---

## In short

- **One command and a clean Mac is ready:** apps, configs, theme, wallpaper. Running it again breaks nothing.
- **Checks itself:** `dot doctor` looks over the whole system in 2 seconds and says how to fix every problem.
- **Easy on memory:** Docker on OrbStack, a prompt with no extra processes, nothing heavy in the background.
- **The code is written by an AI — Claude;** I decide and test. Every such commit is signed, everything passes tests and CI. [More →](docs/details.md#who-writes-the-code)

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/van1dalgrr-arch/dotfiles/main/bootstrap.sh | bash
exec zsh
dot doctor          # everything should be ✓
```

Taking it for yourself — change the name in [`git/.gitconfig`](git/.gitconfig) and trim the [`Brewfile`](Brewfile) first.
Remove it all: `./uninstall.sh --yes`. [How it works →](docs/how-it-works.md)

## Every day

Forgot a command — press `?` in the terminal.

| Command | What |
|---|---|
| `p` | jump to a project in `~/dev` |
| `up` | start the database and the project's API |
| `nvim .` | the editor; `space` — menu of every action |
| `space r h` → `Enter` | **Postman in nvim:** a request to the API, the answer on the right · [guide](docs/postman.md) |
| `orbstack` | containers: table, logs, restart |
| `gg` | git in a friendly interface (lazygit) |
| `dot doctor` | is everything all right with the system |
| `dot backup` | back up unpushed work to GitHub (weekly — it reminds you) |
| `update` | update everything, weekly |
| `theme` · `wall` | change the theme · wallpaper |

## What's inside

| | |
|---|---|
| **Terminal** | [Ghostty](ghostty) — plain, Linux-style: no frame, tabs in the titlebar, drops down on `` ctrl+` `` |
| **Windows** | [AeroSpace](aerospace) — workspaces and alt hotkeys; windows float, no tiling |
| **Editors** | [Neovim](nvim) with Postman and an endpoints list · [Zed](zed) · [Rune](rune) with GoLand keys |
| **Shell** | [zsh](zsh) — a fast own prompt, hints, the `?` cheatsheet |
| **Containers** | OrbStack + an own [`orbstack`](berth) dashboard in Go |
| **Git** | lazygit, readable diffs, a leaked-password guard on every commit ([git](git)) |
| **Look** | 4 themes and 33 live wallpapers that change through the day ([themes](themes), [docs](docs/wallpapers.md)) |
| **Checks** | `dot doctor`, `dot project doctor`, installer tests, CI on every push ([lib](lib), [tests](tests)) |

## Docs

| | |
|---|---|
| [How to use it](docs/guide.md) | every command by topic |
| [Hotkeys](docs/hotkeys.md) | windows, terminal, editors |
| [Postman in nvim](docs/postman.md) | API requests in 5 steps |
| [If something's wrong](docs/troubleshooting.md) | common problems and fixes |
| [If the Mac was wiped](docs/recovery.md) | recovery, including from `dot backup` |
| [**The full story**](docs/details.md) | everything: each part, checks, versions, security, notes from Claude |

---

<div align="center">

[MIT](LICENSE) — take what you like · [changelog](CHANGELOG.md)

</div>
