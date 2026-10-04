# Changelog

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
