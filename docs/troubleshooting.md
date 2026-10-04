# Troubleshooting

<details>
<summary>An app icon went back to the default</summary>

macOS resets custom icons when an app updates. Bring it back with `theme vesper`
(or `swift ~/.cache/dotfiles-theme/icons.swift apply`). Apps installed as root (VS Code, Telegram) need `sudo`.
</details>

<details>
<summary>The terminal didn't change colors after <code>theme</code></summary>

Ghostty reads its config on launch — press `cmd-shift-,` and open a new window.
</details>

<details>
<summary>The drop-down terminal doesn't open</summary>

Ghostty has to be running in the background (AeroSpace starts it at login) and needs Accessibility
permission — global hotkeys don't work without it.
</details>

<details>
<summary>I want starship back</summary>

Put `export PROMPT_ENGINE=starship` in `~/.zshenv` — the config is in `starship/`.
</details>

<details>
<summary><code>dot doctor</code> shows ✗ / ! / ○ — what's what</summary>

`✗` means something required (main `Brewfile`, symlinks, hooks) is broken, and `dot doctor` exits with 1.
`!` is worth a look but doesn't fail the run. `○` is optional (`Brewfile.devops`) and just not set up.
Every line ends with the fix. Add `--deep` for versions, pinned revisions, packages installed outside the Brewfile, and `brew doctor`.
</details>

<details>
<summary><code>brew bundle</code> says Zed / VS Code "already exists"</summary>

The Brewfile skips them when they're already in `/Applications` (installed from the website).
To let brew manage an existing copy: `brew install --cask --adopt zed`.
</details>

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

<details>
<summary><code>macos.sh</code> didn't change anything</summary>

That's on purpose: without `--yes` it only prints the plan. Run `./macos.sh --yes`
(or `./macos.sh --yes finder dock` for specific groups). Keyboard, trackpad and dark mode apply after you log out and back in.
To undo one setting: `defaults delete <domain> <key>` (both are listed in `macos.sh`).
</details>

<details>
<summary>A command does something unexpected (<code>cat</code>, <code>ls</code>, <code>dc</code>, <code>wall</code>)</summary>

Some names are deliberately replaced: `cat`→bat, `ls`→eza, `rm/cp/mv` ask before overwriting, `dc`→docker compose,
and `wall`/`pl` are functions. For the original, use `command cat` or `\cat`.
</details>

<details>
<summary>The shell prints "нет oh-my-zsh"</summary>

`.zshrc` still works without it, but run `./install.sh` to clone oh-my-zsh and fzf-tab at the pinned revisions.
</details>
