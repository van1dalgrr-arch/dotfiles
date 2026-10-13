# Troubleshooting

🇷🇺 [Русская версия](troubleshooting.ru.md) · [all docs](README.md)

Start with `dot doctor`: it finds most of these by itself and prints the fix. Below, grouped by area.

## Look

<details>
<summary>An app icon went back to the default</summary>

macOS resets custom icons when an app updates. Bring it back with `theme vesper`
(or `swift ~/.cache/dotfiles-theme/icons.swift apply`). Apps installed as root (VS Code, Telegram) need `sudo`.
</details>

<details>
<summary>The terminal didn't change colors after <code>theme</code></summary>

`theme`, `wall` and `backdrop` reload Ghostty by themselves over AppleScript. If it didn't happen (Ghostty wasn't
running, or Automation was denied), press `cmd-shift-,`. The prompt and command colors change in **new** windows;
in an open one run `exec zsh`.
</details>

<details>
<summary>I want starship back</summary>

Put `export PROMPT_ENGINE=starship` in `~/.zshenv` — the config is in `starship/`.
</details>

## Terminal

<details>
<summary>The drop-down terminal doesn't open</summary>

Ghostty has to be running in the background (AeroSpace starts it at login; `cmd+q` only closes its windows).
The key is caught by **AeroSpace** (`ctrl-backtick` in `aerospace.toml`), which runs `ghostty/quick-terminal.applescript`,
so Ghostty itself needs no Accessibility permission. The first time, macOS asks whether AeroSpace may control Ghostty:
allow it (System Settings → Privacy & Security → Automation, if you clicked no). After editing `aerospace.toml`: `alt-shift-c`.
</details>

<details>
<summary>A command does something unexpected (<code>cat</code>, <code>ls</code>, <code>dc</code>, <code>wall</code>, <code>docker</code>)</summary>

Some names are deliberately replaced: `cat`→bat, `ls`→eza, `rm/cp/mv` ask before overwriting, `dc`→docker compose,
`orbstack`→berth, and `wall`/`pl`/`docker` are functions (`docker` starts OrbStack when it's off). For the original,
use `command cat` or `\cat`.
</details>

<details>
<summary>The shell prints "нет oh-my-zsh"</summary>

`.zshrc` still works without it, but run `./install.sh` to clone oh-my-zsh and fzf-tab at the pinned revisions.
</details>

## Docker and <code>orbstack</code>

<details>
<summary><code>docker</code> hangs for a few seconds, or prints "запускаю OrbStack…"</summary>

That's the wrapper starting OrbStack because it was off — it takes ~4 s, then the command runs. To keep the engine
up for a while: `orbstack on`. If it doesn't start within a minute, open OrbStack by hand: `open -a OrbStack`.
</details>

<details>
<summary><code>orbstack</code>: "command not found", or old behaviour after an update</summary>

`orbstack` is an alias for `~/go/bin/berth`, built from `berth/`. Rebuild it with `./install.sh` or `update`
(or `go build -C ~/dotfiles/berth -o ~/go/bin/berth .`). `dot doctor` warns when the binary is older than the sources.
In a window opened before the install, run `exec zsh` to pick up the alias.
</details>

<details>
<summary><code>orbstack</code>: the dashboard says "движок выключен"</summary>

Press `e` to start the engine, or just do anything with a container — it starts the engine itself.
`E` stops it and gives the memory back.
</details>

<details>
<summary><code>orbstack</code>: <code>f</code> shows image layers instead of a Dockerfile</summary>

The Dockerfile is found through the compose labels on the container. If the container was started with `docker run`,
or its compose service uses a ready `image:` instead of `build:`, there is no Dockerfile to show, so the image layers
are shown instead — the steps it was built from. If the compose file moved, the labels still point to the old path:
recreate the containers with `docker compose up -d`.
</details>

<details>
<summary><code>orbstack watch</code> changed my compose file</summary>

Only after asking: it adds a `develop.watch` block to services with `build:`. Comments and key order stay;
blank lines between services may go. `git diff` shows exactly what changed; `git checkout -- compose.yaml` undoes it.
</details>

## Go

<details>
<summary>A Go tool has the wrong version, or <code>dot tools</code> shows <code>!</code></summary>

Versions are pinned in `go/tools.txt`. Run `dot tools install` to install exactly those versions.
To upgrade, change the version in the file first. tflint lives in `go/tools.devops.txt`
(Homebrew dropped the formula): `dot tools install devops`.
</details>

<details>
<summary>A project needs a newer Go than the one installed</summary>

You don't need to do anything: with the default `GOTOOLCHAIN=auto`, Go downloads the version from
`go.mod` (`go 1.N` / `toolchain go1.N.x`) on first build. If it fails, check `go env GOTOOLCHAIN`.
It shouldn't be `local`.
</details>

## Editors: Rune and Neovim

<details>
<summary>Rune: <code>dot doctor</code> says "Rune rewrote ~/.rune/config.yaml over the link"</summary>

On start Rune merges its packages' blocks into the config and saves the whole file, which turns the link into a plain file.
Look at the difference and take it into the repo:
`diff ~/dotfiles/rune/config.yaml ~/.rune/config.yaml`, then
`cp ~/.rune/config.yaml ~/dotfiles/rune/config.yaml && ln -sf ~/dotfiles/rune/config.yaml ~/.rune/config.yaml` and commit.
</details>

<details>
<summary>Rune: a key does nothing</summary>

First check that AeroSpace didn't take it: it owns `alt-h/j/k/l`, `alt-r`, `alt-q`, `alt-e`, `alt-enter`,
`alt-1…9` and everything with `alt-shift`. That's why Rune keys are on `cmd`, `ctrl-alt`, `cmd-alt` and F-keys.
F-keys on a Mac need `fn` (`fn-F8`). Rune writes config errors to `~/.rune/debug.log`:
`grep -i 'error occurred' ~/.rune/debug.log | tail -1`.
</details>

<details>
<summary>Neovim: no completion and no go-to-definition</summary>

The language server isn't installed yet or crashed. `:Mason` — what's installed; `:LspInfo` — what's attached to the file;
`:checkhealth` — everything. The first run in a Go project builds gopls from source — that takes a couple of minutes.
</details>

<details>
<summary>Neovim: Mason doesn't install servers, the log says <code>npm error EACCES</code></summary>

`~/.npm` has root-owned folders (someone ran `sudo npm` once). It's only a cache: `mv ~/.npm ~/.npm.old`
and reinstall from `:Mason`. Remove the old folder later: `sudo rm -rf ~/.npm.old`.
</details>

<details>
<summary>Neovim: no highlighting, an error about <code>tree-sitter-cli</code></summary>

The new nvim-treesitter builds parsers itself and needs `tree-sitter-cli` for it: `brew install tree-sitter-cli`
(it's in the Brewfile), then `:TSUpdate` in Neovim.
</details>

## macOS and <code>dot doctor</code>

<details>
<summary><code>dot doctor</code> shows ✗ / ! / ○ — what's what</summary>

`✗` means something required (main `Brewfile`, symlinks, hooks) is broken, and `dot doctor` exits with 1.
`!` is worth a look but doesn't fail the run. `○` is optional (`Brewfile.devops`) and just not set up.
`·` is information. Every line ends with the fix. Add `--deep` for versions, pinned revisions, packages installed
outside the Brewfile, and `brew doctor`.
</details>

<details>
<summary><code>dot doctor</code>: "настроек macos.sh не на месте"</summary>

A macOS upgrade (or a click in System Settings) put some settings back. `./macos.sh` shows which ones,
current value → expected; `./macos.sh --yes` restores them. Changed on purpose? Edit or delete that line in `macos.sh`.
</details>

<details>
<summary><code>dot doctor</code>: "awake включён"</summary>

`awake on` stops the Mac from sleeping even with the lid closed — handy for Claude Code from the phone, bad in a
backpack. `awake off` when you're back (asks for the password).
</details>

<details>
<summary><code>brew bundle</code> says Zed / VS Code "already exists"</summary>

The Brewfile skips them when they're already in `/Applications` (installed from the website).
To let brew manage an existing copy: `brew install --cask --adopt zed`.
</details>

<details>
<summary><code>macos.sh</code> didn't change anything</summary>

That's on purpose: without `--yes` it only prints the plan. Run `./macos.sh --yes`
(or `./macos.sh --yes finder dock` for specific groups). Keyboard, trackpad and dark mode apply after you log out and back in.
To undo one setting: `defaults delete <domain> <key>` (both are listed in `macos.sh`).
</details>

<details>
<summary><code>macos.sh safari</code>: "нет доступа" / "не проверить"</summary>

Safari keeps its settings in a sandbox: the terminal can't read or write them without
System Settings → Privacy & Security → **Full Disk Access** → Ghostty (restart Ghostty after). Apply, then take the
access back: `tccutil reset SystemPolicyAllFiles com.mitchellh.ghostty`.
</details>
