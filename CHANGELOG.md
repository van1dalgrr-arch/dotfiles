# Changelog

## Unreleased

- **Terminal effects: `fx`.** New shaders: `sparks` (sparks as you type), `focus` (the focused window flashes along its edges), `glow` (soft neon halo on bright text). `fx` toggles any of them, plus the smooth `cursor` and `trail`
- Shaders take colors from the terminal theme (`iCursorColor`, `iPalette`) instead of baked-in hex: the trail now follows light mode, and `theme` no longer generates a shader copy
- **Ghostty reloads by itself** after `theme`, `wall`, `backdrop` and `update` (AppleScript `reload_config`), no more `cmd+shift+,`
- `backdrop` reuses a background already built for the same wallpaper: the menu opens in ~30 ms instead of 1.2 s
- `wall` labels each entry as live wallpaper or photo; `up` gives up on OrbStack after a minute instead of waiting forever; `killport` sends TERM first and KILL only after 2 s
- **Quick terminal from any app** without granting Ghostty Accessibility: AeroSpace catches `` ctrl+` `` and toggles it through Ghostty's AppleScript (`ghostty/quick-terminal.applescript`)
- **Photo wallpapers:** `wall add <photo> [name]`. Photos are denoised, upscaled to the screen (two-step Lanczos), cropped and sharpened by `icons/photo-wallpaper.swift`. They live in the git-ignored `wallpapers/photos/`
- Photos for wallpapers are backed up to a private repo (`dotfiles-photos`); `wall add` pushes new ones automatically
- **Chrome dropped:** previews render with the WebKit built into macOS (`icons/html2png.swift`); Safari takes workspace 3
- **Docs:** a README in every folder, in English and Russian; `docs/guide.ru.md` lists every command; comments trimmed to the useful ones
- **Screenshots** rendered from real output: a tiled desktop (Ghostty + Zed, glow from the wallpaper) and `dot doctor`; `FORCE_COLOR=1` keeps `dot` colors when piped
- `theme` rebuilds the terminal backdrop for its wallpaper; `brew doctor` cleaned up (untrusted tap removed, libtiff/webp fixed)

## v1.2.0 — 2026-10-06

**Reproducibility**
- `go` is now in the Brewfile (it was only installed as a dependency)
- Go tools are pinned in `go/tools.txt`; `dot tools [install]` installs exactly those versions (no `@latest` anymore)
- oh-my-zsh and fzf-tab are cloned at pinned commits by `install.sh` (oh-my-zsh used to be a manual step)
- Zed and VS Code are in the Brewfile, skipped when they're already in `/Applications`

**DevOps**
- `Brewfile.devops` (optional): kind, kustomize, opentofu, terraform-docs; tflint via `go/tools.devops.txt`
- Aliases `tf` (tofu) and `pd` (`dot project doctor`)

**dot**
- `dot doctor` checks Homebrew, Go, Docker/Compose, Kubernetes, IaC, git hooks, Ghostty and Zed; required vs optional (`○`)
- `dot doctor --deep`: versions, pinned revisions, packages outside the Brewfile, `brew doctor`, Zed JSONC, PATH duplicates
- `dot project doctor`: Go project checklist (go.mod, tests, linters, Docker, compose, migrations, .env safety)
- Modules live in `lib/`; works with the system bash 3.2; exit codes 0 / 1 / 2

**macOS**
- `macos.sh` only prints a plan (current → new) unless you pass `--yes`; groups for keyboard, trackpad, Finder, saving, screenshots, Dock and appearance

**Shell**
- `.zshrc` no longer breaks when a tool or oh-my-zsh is missing; `typeset -U path`; optional mise hook

**Zed**
- New light theme **Dev Day**, generated from Dev Night by `zed/tools/light.py` so the two stay in sync. It switches with macOS appearance
- Themes and icons are two Zed extensions, `zed/dev-night-theme` and `zed/dev-night-icons` (MIT), laid out the way the Zed registry wants; generators live in `zed/tools/`

**Light mode**
- Ghostty and the shell follow macOS appearance. The light palette **Dev Day** (`themes/light/day.sh`) matches the Zed theme
- `apply.sh` generates `dotfiles-dark` / `dotfiles-light` Ghostty themes plus light copies for eza, bat, lazygit, starship and delta (`DELTA_FEATURES=+day`)

**Zed extensions**
- github-actions (workflow LSP: action inputs, `${{ }}` expressions), postgres-language-server (lints SQL migrations without a database), typos, mermaid
- Kubernetes schema for `k8s/`, `deploy/k8s/` and `manifests/` YAML

**Terminal look**
- Two-line framed prompt: `╭─[user@host]─[path]─[git]─[context]` / `╰─$`, real user and host (red over SSH)
- kubectl context `⎈` in the prompt when it matters (k8s project, or after kubectl/helm in that window), read from the kubeconfig file
- Ghostty without a titlebar and with a block cursor, like a terminal in a tiling WM; macOS logo in the greeting; `palette` shows the theme colors

**Reminders**
- Under the greeting of a new window, only when there is something: `update` not run for 7+ days, repos in `~/dev` with unpushed commits (any branch) or uncommitted files. Repo status is cached and refreshed in the background, adding about 8 ms to the greeting

**GoLand / JetBrains**
- Dev Night and Dev Day as `.icls` editor color schemes, generated from the Zed theme by `jetbrains/build.py` (Go, Markdown, console, diff, search highlights)

**Smooth cursor**
- Ghostty cursor glides to its new position like VS Code's smooth caret (`ghostty/shaders/cursor_smooth.glsl`): theme color, native blink, inverted glyph for block, hollow when unfocused. The trail on big jumps stays
- `make check` compiles the Ghostty shaders with glslang (Ghostty's own header) when it's installed

**Terminal backdrop**
- `backdrop` sets a Ghostty background made from the current wallpaper: glow, aurora, haze, glass or off. Only the wallpaper's colored light is kept, so it suits both dark and light mode. `wall` regenerates it

**New Mac**
- `bootstrap.sh`: Command Line Tools, Homebrew, clone and `make install` in one `curl | bash`; `--dry-run` shows the plan
- `macos.sh apps`: code files (.json, .yaml, .sh, .sql, .env…) open in Zed; `macos.sh login`: Raycast at login

**Completion**
- Tab completion for `dot` (commands, `doctor --deep`, `tools`, `macos` groups), `theme`, `wall`, `backdrop` and `awake`; themes and wallpapers are read from the repo

**Git**
- `pull --rebase`, autosquash and updateRefs, `push.followTags`, verbose commits with a message template, version-sorted tags, untracked cache
- Aliases `undo`, `amend`, `wip`/`unwip`, `fixup` (fzf), `recent`, `gone`/`tidy`, listed in the `?` cheatsheet

**gonew 2.0**
- New projects come with CI (tests, lint, govulncheck, Docker), a `/health` test with a fake DB, golang-migrate migrations, `make help`, a README with the CI badge; `--gh` creates a private GitHub repo and pushes

**Tests**
- `pre-push` in this repo runs `make check` and the smoke tests; a broken change doesn't reach GitHub (`--no-verify` to skip)
- `tests/smoke.sh` (`make test`), run in CI on Linux and macOS; Brewfile syntax and bash 3.2 parse checks

## v1.1.0 — 2026-10-05

**Tooling**
- `dot` CLI: `dot doctor` checks symlinks, Brewfile tools, Go tools, font, theme, Ghostty config, zsh startup, git hooks, Docker
- `uninstall.sh`: dry run by default, `--yes` removes symlinks and restores `*.bak`, `--purge` cleans generated theme files
- `Makefile`: `make install`, `make check`, `make update`; `.editorconfig`

**Backend**
- pgcli, golang-migrate, sqlc, grpcurl, buf, oha, fx, watchexec, act, trivy, helm, kubectx, stern, govulncheck, gofumpt
- New commands: `db` (pgcli into the project database), `vuln` (govulncheck + trivy), `load` (oha load test)
- Yaak instead of Postman, TablePlus for databases — both with glass icons

**Zed**
- Delve debugger configs (`f5`): `cmd/api`, current package, test under the cursor
- golangci-lint as a language server, `.http` request files, more tasks, keys and Go snippets

**Look**
- 6 new wallpapers: crystal, vinyl, iso, topo, startrails, helix (25 total)
- Glass folder icons for dev, Downloads, Documents, Desktop, Pictures, Music, dotfiles

**Docs**
- Wallpaper gallery, hotkeys, themes and troubleshooting pages in `docs/`; screenshots of Ghostty and Zed

**Fixes**
- Arch greeting never showed: Ghostty inherits `SHLVL` from AeroSpace; now uses an env flag
- JankyBorders removed (not installed, not wanted)

**CI**
- macOS job: typecheck every Swift generator, apply every theme in a clean `HOME`

## v1.0.0 — 2026-10-05

First public release.

**Terminal**
- Ghostty with a drop-down window (`ctrl+``), cursor trail shader, notifications for long commands
- Pure-zsh prompt (no starship): repo-relative path, git status, Go version from `go.mod`, transient prompt
- Arch-style greeting with fastfetch and a random tip from the cheatsheet
- `command not found` suggests the brew package, like `pkgfile` on Arch

**Workflow**
- `p`, `up`, `pl`, `gonew`, `got`/`gotw`, `ram`, `update`, `dsh`, `dlogs`, `gco` and a `?` cheatsheet
- `gonew` scaffolds a Gin + Postgres service: cmd/api, internal, compose, distroless Dockerfile, Makefile, CI-ready
- Docker on OrbStack instead of Docker Desktop

**Look**
- Theme switcher (`theme`): vesper, kanagawa, rose-pine — recolors terminal, tools, Dock and folder icons, wallpaper
- 22 live wallpapers drawn in Swift (`wall`), 12 frames per day, applied to all Spaces
- Glass-style Dock and folder icons
- Zed: Dev Night theme, Dev Night Icons, tasks and Go snippets

**Safety**
- gitleaks before every commit, global `.gitignore` for secrets
- CI: shellcheck, zsh syntax, JSON, gitleaks
