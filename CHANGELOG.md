# Changelog

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
