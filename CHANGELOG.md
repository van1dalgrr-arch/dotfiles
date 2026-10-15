# Changelog

## Unreleased

- **Neovim: background tests, code screenshots, tip of the day.** After a save (debounced for autosave) `go test -json` runs for the file's package — results come from the go test cache when nothing changed; the status line shows `✓ 42` / `✗ 1` / `✗ сборка`, failed checks become diagnostics on their `_test.go` lines, a notification only when it turns red; `space t A` toggles. `space P` renders the selection or the function at the cursor with charmbracelet freeze (window, shadow, line numbers, the current theme or its closest freeze twin) into `~/Pictures/code` and the clipboard as PNG; `freeze` goes in the Brewfile from charmbracelet/tap (plain `freeze` is an unrelated cask). The start screen shows a random line from the cheat sheet (153 tips). Checked in tmux on a throwaway module: break `Add` → `✗ 1` and `● TestAdd: got -1, want 3` on the line, fix → `✓ 2`, marks gone
- **Neovim theme switcher (`alt-s`, `space u C`):** a list on the right with the current file (or a Go sample) under it, the whole editor repaints as you move, `enter` remembers the pick in `~/.local/state/nvim/colorscheme` and nvim starts with it, `esc` restores. Vim's built-in schemes are hidden; extra themes are lazy again — the snacks finder sees unloaded plugins' `colors/`. Checked in tmux: cancel restores, enter saves, restart loads
- **Neovim, round three:** surround (`gsa`/`gsd`/`gsr`), dial with Go cycles (`:=`↔`=`, `==`↔`!=`, `t.Error`↔`t.Fatal`, slog levels, HTTP methods and statuses), yank history (`space p`), `.env` values masked by cloak.nvim with the cursor line revealed (`space u e`). precognition shows only `w b e ^ $ %` — the f/t targets turned the hint line into noise. Start screen: the logo lines padded to one width (the last two drifted right) and git status drawn as text instead of a terminal block that printed `[Process exited 0]`. lazy's luarocks support off — no plugin needs it. Checked in a real TUI through tmux: dial, surround and cloak do what the cheat sheet says
- **Neovim, round two:** learning aids — precognition marks where `w`/`b`/`e`/`$`/`{`/`}` land, hardtime in hint mode (nothing blocked, arrows kept for multicursor); `alt-c` hides/shows Claude from anywhere including its own terminal, `space a x` sends the error under the cursor to Claude; `gw` in a float on `alt-w` / `space g w`; yazi.nvim; a Go scratch module (`space r g`); structural search and replace through grug-far + ast-grep (`space s A`, `ast-grep` added to the Brewfile); JSON → struct (`space G p`, gopher's json2go); compiler optimization details toggle (`space G o`); SQL highlighted inside Go strings (`queries/go/injections.scm` — `\(…\|…\)` silently never matches in a query predicate, very magic `\v` does); quicker.nvim; breakpoints persist across restarts. tokyonight gets glass floats and sidebars, quiet inlay hints, thin separators. Fixed: ▶ hid the diagnostic sign on its line (now skipped there), `[default]` after gopls messages, the noisy `a...:` parameter hints
- **Neovim, stronger than GoLand:** ▶ next to `func main` and tests (`space r x` runs the function at the cursor through neotest or a terminal, `space r X` under delve); `реализует: io.Reader` next to types (goplements); code actions with a delta diff preview (tiny-code-action) and direct extract / inline / rewrite (`space c x` / `c i` / `c w`); call hierarchy; gopher.nvim generation on `space G` (tags, implement an interface, `if err`, gotests, `go mod tidy`); peek windows (`gpd` / `gpr` / `gpi`); line coverage from `go test -coverprofile` (`space G v`); go.mod code lenses; the `shadow` analysis; GoLand F-keys `S-F6` rename and `F2` next error; attach to dlv in Docker on :2345; a benchmarks + pprof task; Go snippets (`ife`, `errw`, `tt`, `gh`, `bench`…). UI: breadcrumbs (dropbar), a sticky function header, the Structure window, rename with a preview, Error Lens-style diagnostics, multiple cursors. Git: diffview (three-way merge, file history, the branch against main), current-line blame, the built-in 0.12 undotree as Local History. Claude Code inside nvim (claudecode.nvim) and kubectl.nvim. Checked headless on github-watcher: gopls attaches, ▶ marks and goplements text appear, every new plugin loads
- **Neovim look:** tokyonight night stays the default; `space u C` adds kanagawa, nightfox/carbonfox, cyberdream, vesper, gruvbox-material and rose-pine. rose-pine takes the dotfiles theme colors — `lua/dotfiles/theme.lua` reads `themes/<theme>.sh` (the roles are Rosé Pine's) into rose-pine's palette, and `themes/light/day.sh` for macOS light mode; `theme <name>` repaints an open nvim through a file watcher while rose-pine is active. Own highlight groups (▶, goplements, multicursor) get theme-independent defaults. Transparent background, rounded borders on every float, a bubbles status line with the attached LSP and the time, a new start screen with recent files, projects and git status. Cheat sheet in both languages (`docs/nvim.md`, `docs/nvim.ru.md`): vim beyond `dd` and `i`, GoLand → nvim key by key; `space h` opens it inside nvim
- **Neovim on LazyVim (`nvim/`):** the LazyVim starter, linked to `~/.config/nvim`, as a ready escape hatch from Rune/Zed: Go (gopls, delve, golangci-lint, gofumpt, neotest), Docker, YAML, JSON, Markdown, debugger and test runner from LazyVim extras; tokyonight night, transparent. No background update checks; `lazy-lock.json` pins plugins. `neovim` and `tree-sitter-cli` (the new nvim-treesitter builds parsers with it) are in the Brewfile. Checked headless: 33 parsers build and gopls attaches to a Go file
- **Rune like GoLand:** a JetBrains-style keymap on cmd / ctrl-alt / cmd-alt / F-keys (AeroSpace owns the alt layer, so half of the old Rune keys never reached it): `cmd-B` definition, `cmd-alt-B` implementations, `alt-F7` usages, `shift-F6` rename, `ctrl-T` every gopls refactoring in a list, `ctrl-alt-R` run, `ctrl-shift-R` test at cursor, `ctrl-alt-D` debug with dlv, `F7`/`F8` stepping, `ctrl-alt-W` vet+tests watchers, `ctrl-alt-L` golangci-lint as a jump list. `bin/rune-go` finds the module and the main package from the focused file and prints lint/vet/build errors as `path:line:col`
- **Rune config survives Rune:** Rune merges its packages' blocks (go, fuzzy-search) into `config.yaml` on start and rewrites the file, which replaced the symlink every time. The repo now keeps the config in Rune's own format with those blocks, so there is nothing left to merge. Fixed the extension path typo (`rune-do`), `workspace.home: ~` (YAML null) and a mis-ordered modifier; `dot doctor` checks the extension path
- **Ghostty, a plain Linux look:** tabs in the titlebar (one slim bar instead of two), no window buttons or shadow, flat background without the wallpaper backdrop, block cursor without blink (also at the prompt), thinner font, padding 12×8. Effects default to cursor + trail; glow and focus flash stay available in `fx`
- **The greeting draws the Ghostty ghost** instead of the Apple logo: half-block pixel art with the `>–` face cut out (`fastfetch/ghost.txt`)
- **Rune, the next editor (`rune/`):** config for [Rune](https://rune.build), the Go-native GPU IDE I'm moving to from Zed gradually — the Dev Night theme ported to Rune's 16-color palette, font 15, zsh, `:doctor`/`:gotest`/`:lg` aliases; telemetry, the daily update check and auto-joining Rune's network are off, so it sends nothing by itself. `rune-dot`, a Rune extension in Go (`rune-go-sdk`): `:work <mode>`/`:work off` with completion and `:projectdoctor`, results as notifications; tested with fakes, built by `install.sh`, checked by `make check`, CI and Dependabot. `dot doctor` lists Rune as optional
- **Zed:** sticky scroll, colored brackets, `existing_window` for `zed file`, minimap off, YAML/JSON formatted by their language servers (no prettier), more JSON schemas (dependabot, goreleaser, sqlc, buf, Chart, prometheus), Docker tasks (compose ps/config, build, hadolint, trivy) and `govulncheck` / `dot project doctor` / `dot work` tasks. gopls `vulncheck` is `Off` — `Imports` fetched vuln.go.dev on every project open; vulnerabilities are checked on demand
- **Chrome wallpapers:** `chrome`, `chrome-arc`, `chrome-cables` — liquid-metal tubes on near-black with real reflections (`CIHeightFieldFromMask` + `CIShadedMaterial` reflecting a small studio: bright sky, dark ground, rim lights in the day's tint). Tubes overlap and cast shadows; reflections slide along them over the day. ~1 s a frame on the GPU. The renderer lives in `wallpaper-kit.swift` (`chromeScene`), so a new chrome wallpaper is just a list of curves
- **`dot work` — project modes:** `work kinoza-back` starts OrbStack (with `orb start`), the project's containers or compose services without `build:`, opens Zed and goes to the folder; the prompt shows `◆ kinoza-back 1h12m`. `work off` stops them, quits every regular app except Finder, Happ and Ghostty, turns OrbStack off when no other containers run, and reports what's still up (including Claude Code sessions in the project). Modes live in `work/<name>.work`, not in the project repo
- **`dot sync`:** pull fresh dotfiles safely — shows incoming commits and files, fast-forward only (refuses on diverged branches; git refuses to overwrite local edits), then smoke tests and `dot doctor`, and tells what to rerun (install.sh, brew bundle, berth, exec zsh)
- **`dot doctor --json`:** `{summary, checks: [{section, status, message, hint}]}` for jq, CI and dashboards; plain bash 3.2, no jq needed to produce it
- **Installer tests (`tests/install.sh`):** install/uninstall on a copy of the repo with a temp HOME — re-runs, backups, broken and foreign symlinks, restore byte for byte. They found and fixed three bugs: a second file in place of a link overwrote the original `.bak` (now `.bak.1`, `.bak.2`…), and foreign symlinks — your own link to Dropbox, or a broken one — were deleted without a backup (now moved to `.bak`, and uninstall restores them). Run by `make test`, CI (Linux and macOS with bash 3.2) and pre-push
- **CI hardened:** `permissions: {}` by default and read-only per job, third-party actions pinned to full commit SHAs, `persist-credentials: false`, actionlint (checksum-verified) checks the workflows, Dependabot updates the pins and berth's Go modules weekly
- **Fixed: `docker` didn't wake OrbStack after `orb stop`** — the app keeps running, so `open -ga OrbStack` did nothing and docker waited a minute; now it's `orb start`

- **`github` — GitHub in the terminal** ([github-watcher](https://github.com/van1dalgrr-arch/github-watcher), code written by an AI — Claude): a dashboard in the style of `orbstack` with PRs, issues, Actions logs and an event feed, plus Telegram notifications from GitHub Actions. Installed as `gw` from `go/tools.txt` (so `install.sh`, `update` and `dot doctor` handle it), `.zshrc` aliases `github` to it
- **Documentation remodelled, every page in English and Russian:** a Russian root README (`README.ru.md`); English versions of the guide, how it works, recovery, macOS upgrade and the containers guide; Russian versions of troubleshooting, hotkeys, themes and the wallpaper gallery; a language switch at the top of every page. Updated for this release: an `orbstack` section with a screenshot and its keys everywhere, the `docker` auto-start, live rebuild, Safari, the new `dot doctor` checks, missing AeroSpace and Ghostty keys, troubleshooting grouped by area with `orbstack` cases. Fixed claims that went stale (Ghostty reloads by itself, effect shaders take theme colors without a copy, fzf follows the theme). Every relative link and section anchor checked
- **`orbstack`: look inside containers.** `i` — a readable inspect (image, state, command, ports, mounts, networks, env with passwords and tokens hidden); `f` — the container's Dockerfile, found through its compose project, or the image layers when it was started from a prebuilt image; `c` — the project's compose file. All in a scrollable viewer with syntax highlighting (bat). The mouse works: wheel moves through the list, a click selects, a second click opens the actions. Fixed: "inspect" used to print and vanish at once
- **`orbstack` rewritten in Go (`berth/`, Bubble Tea):** one live screen instead of a menu loop — containers with CPU and memory refreshing in the table, the selected container's log and a live event feed below. Everything on keys (`enter` actions with explanations and the docker command, `l` logs, `s` shell, `r` restart, `x` stop/start, `n` new from a template with an editable command, `t` stats, `w` live rebuild, `?` all keys). The same subcommands as before (`orbstack run postgres`, `logs`, `up`, `watch`, `on`/`off`…); commands that need the engine start it themselves. `install.sh` and `update` build it, `dot doctor` warns when the binary is older than the sources, `make check` and CI run `go vet` and the tests. The zsh version (`zsh/orb.zsh`) is gone
- **`orbstack watch`:** live rebuild — save the code and Docker rebuilds the image and restarts the container (`docker compose watch`). If the compose file has no `develop.watch` block, it shows the block, asks, and adds it with yq for every service with `build:`; suggests a Go build cache in the Dockerfile so rebuilds take seconds
- **`orbstack`:** containers in the terminal. Home screen: a gradient banner in the theme colors, engine status and a table of containers (● running / ○ stopped / ● created, short ports). Menu with an explanation and the underlying docker command for every item: containers (logs with live preview, shell, restart, stop/start, inspect, remove), **run** from templates (postgres, redis, nginx, mongo, mysql, rabbitmq) or any image — shows the `docker run` command and lets you edit it first, **top** (live CPU/memory/network), **events** (live start/stop/die/oom/health feed), compose up/down, images, cleanup, engine on/off, and a guide. Every action is also a subcommand; `ctrl+c` in logs or monitoring returns to the menu
- **`docs/docker.ru.md`:** how to run containers from the terminal — `docker run` flags explained, compose, cleanup (`orbstack guide`)
- **`docker` starts OrbStack by itself:** any docker command (`docker ps`, `dps`, `dsh`…) launches OrbStack when it's off and waits for it (~4 s), instead of failing with "failed to connect to the docker API" — that happened 20 times in a week. `up` uses the same helper; `update` and `lean` only probe and never start it
- **README rewritten:** contents bar, requirements, "Using it yourself" (git identity, Brewfile, macos.sh), health checks table, macOS settings as a table, Security and Development sections
- **`dot doctor` notices settings drift:** runs `macos.sh` read-only and warns when a macOS upgrade put settings back; warns when `awake` is left on; checks App Store apps from the Brewfile (`mas` lines); zsh startup is the best of three runs (one cold run used to report 0.7 s)
- **Safari:** `./macos.sh safari` — full address, link status bar, Develop menu (Safari 26 keeps it in `com.apple.Safari.SandboxBroker`), no preloading, downloads don't open themselves. Without Full Disk Access it says it can't check instead of reporting every key as changed. uBlock Origin Lite in the Brewfile via `mas`; `safari/user.css` puts JetBrains Mono in code on every site
- `macos.sh`: `~/path` and the full path count as the same value; the relogin hint shows only for groups that need it
- `make check` no longer prints temp file paths while compiling shaders
- **`backdrop` menu fixed:** it no longer pre-renders every wallpaper before showing the list (that took minutes and aborted on the classic generators). The list opens at once, styles on top; a wallpaper is rendered only when picked, through the same builder as `wall`. A style named like a wallpaper (`glass`, `aurora`) no longer trips the hourly refresh
- **`dot snapshot`** before a macOS upgrade and **`dot snapshot diff`** after: installed brew packages and apps with versions, macos.sh settings, login items, background agents, tool versions, AeroSpace permission — shows what reset. Checklist: `docs/macos-upgrade.ru.md`
- **`dot doctor` checks macOS itself:** FileVault, firewall, SIP, Gatekeeper, Time Machine (no backups → warning), free disk; `--deep` adds battery capacity and pending macOS/Safari/CLT updates
- `./macos.sh security`: firewall on + stealth mode (plan first, `--yes` asks for sudo)
- `glslang` is in the Brewfile (`make check` compiles the Ghostty shaders with it)
- **`lean`** for 8 GB: a report (memory pressure, heavy apps, third-party agents that start by themselves, a hint when Ghostty has piled up cache after many theme/backdrop changes); `lean on` quits heavy apps from `~/.config/dotfiles/lean` (default OrbStack, Telegram, Discord, Spotify, G Hub; OrbStack only when no containers run) and shows memory before/after; `lean off` reopens them
- **Five atmospheric wallpapers:** `mistcity`, `hanami`, `snowfall`, `cosmea`, `steppe` — fog, dusk and snow, painted in code at screen resolution with depth of field and film grain (`wallpaper-kit` gained `haze`, `soften`, `filmic`, `blurLayer`, towers and wires)
- **Any wallpaper in the terminal:** `backdrop <name>` takes any `wall` name — a live scene or your photo — and puts a dark, readable version behind the terminal (`icons/terminal-grade.swift`); brightness is normalized so text reads at any hour; a new terminal window refreshes it in the background when the 2-hour slot changes
- **Quick terminal fixed:** `` ctrl+` `` now gives it keyboard focus without raising Ghostty's other windows (`ghostty/activate.swift` activates only the key window; AppleScript `activate` pulled the regular Ghostty window over the current app). Before, focus stayed in the previous app, so typing went there and the terminal never auto-hid
- Ghostty windows have their close / minimize / zoom buttons back (transparent titlebar instead of hidden)
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
