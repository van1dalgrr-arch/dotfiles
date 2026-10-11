# How to use it

🇷🇺 [Русская версия](guide.ru.md) · [all docs](README.md)

Everything the setup can do, by area, with commands. How it's built inside is in
[how-it-works.md](how-it-works.md); if the Mac was wiped, see [recovery.md](recovery.md).

Forgot a command? Press **`?`** (or `ctrl+/`) in the terminal: a cheatsheet with every command and hotkey.
Started typing? Press **`Tab`**: it suggests themes, wallpapers, backdrop styles and `dot` commands.

---

## The most common

| Command | What it does |
|---|---|
| `p` | jump to a project in `~/dev` (picker with a preview) |
| `pl` | all projects at once: branch, changes, how long since the last commit |
| `up` | run the project: the database in Docker + the app with hot reload |
| `got` / `gotw` | tests / tests again on every save |
| `gco` | switch git branch (with a picker) |
| `orbstack` | containers: a live dashboard with logs, events, CPU and memory |
| `theme` · `wall` · `backdrop` · `fx` | theme · wallpaper · terminal backdrop · effects |
| `update` | weekly maintenance |
| `dot doctor` | is everything in order |
| `?` | cheatsheet |

---

## 1. Look: theme, wallpaper, terminal backdrop

Three independent things that work together:

```
theme    ──▶ colors of everything (terminal, prompt, icons) + this theme's wallpaper
wall     ──▶ only the wallpaper (any), colors untouched
backdrop ──▶ a glow behind the terminal text, made from the CURRENT wallpaper's colors
```

The chain runs by itself: change the theme → its wallpaper is set → the backdrop is rebuilt for its colors.
Change the wallpaper with `wall` → the backdrop is rebuilt too. `wall` doesn't change the theme.

Ghostty **reloads its config by itself** after `theme`, `wall`, `backdrop` and `update` — nothing to press.

### Theme — `theme`

```bash
theme            # pick with a color preview
theme vesper     # directly (the default)
theme kanagawa
```

Recolors the terminal, prompt, command highlighting, fzf, eza, bat, lazygit, git diff, app and
folder icons, and sets the theme's wallpaper. Pictures of all themes: [themes.md](themes.md).

**Light mode.** When macOS switches to light appearance (Settings → Appearance), Ghostty turns light
by itself (**Dev Day**), and so does Zed. The prompt and command colors follow in **new** windows
(in an open one: `exec zsh`). To pin one look regardless of macOS: `export DOTFILES_APPEARANCE=dark`
(or `light`) in `~/.zshenv`.

`palette` shows the current theme's colors.

### Wallpaper — `wall`

```bash
wall             # list with an image preview right in the terminal, Enter to apply
wall eclipse     # directly
wall sakura      # your photos are in the same list
```

- **Live wallpapers** (eclipse, orbit, aurora, foggy mistcity, hanami… — 30 of them) are drawn in code and
  **change through the day**: morning, day, evening, night. Gallery: [wallpapers.md](wallpapers.md).
- **Your photos** (sakura, fog, snow…): static, upscaled to the screen without blur.
- Applied to **every Space** at once.

**Add your own photo:**

```bash
wall add ~/Downloads/photo.jpg rain     # rain is the name it gets in the list
```

A small or compressed photo is processed automatically: JPEG noise removed, upscaled to the screen
(2560×1664), center-cropped, lightly sharpened. Photos live in `~/dotfiles/wallpapers/photos/`, which never
reaches the public dotfiles (`.gitignore`) but is itself a **private** repo, `dotfiles-photos`: `wall add`
pushes every new photo there right away — that's the backup.

### Terminal backdrop — `backdrop`

```bash
backdrop          # pick a style with a preview
backdrop glow     # directly
backdrop hanami   # any wallpaper from wall as the terminal background
backdrop off      # no background
```

**Any wallpaper** from `wall` (live scenes and your photos, e.g. `backdrop mistcity`) becomes the same picture,
only dark and calm: brightness is normalized and the left side (where the text is) is darker, so text reads
at any hour. It uses the current hour's frame and is rebuilt every 2 hours on the next `backdrop`, `wall` or `theme`.

| Style | Looks like |
|---|---|
| **glow** | the wallpaper's colors shining from the bottom-right and top-left corners |
| **aurora** | wavy ribbons of light along the bottom edge |
| **haze** | a soft blurred cloud of the wallpaper's own light |
| **glass** | the wallpaper itself, faint, as if through frosted glass |
| **off** | no background |

Only the colored highlights are taken from the wallpaper and the dark parts are transparent, so the backdrop
suits both the dark and the light theme. The style is remembered; `wall` and `theme` rebuild it.
The styles are pictured in the README, section *Terminal backdrop and effects*.

### Terminal effects — `fx`

```
fx                # picker: Tab to mark, Enter to toggle
fx on sparks      # sparks as you type
fx off trail      # no trail
fx set none       # no effects (a plain cursor)
```

`cursor` — smooth cursor · `trail` — a trail on jumps · `sparks` — sparks as you type ·
`focus` — the focused window flashes along its edges · `glow` — glowing text (dark theme only).
Colors come from the theme, so `theme` and light mode recolor the effects at once.

---

## 2. Terminal

### Prompt

```
╭─[dev@van1dal]─[logsence/internal]─[ main +1 !2 ?3 ⇡1]─[ 1.27.1 󰡨 ⎈ orbstack]    󱎫 3s · 13:42
╰─$
```

| Part | Meaning |
|---|---|
| `dev@van1dal` | user@computer; over SSH the computer is red |
| path | from the git repo root, project name in bold |
| `+1` `!2` `?3` | staged · modified · new files |
| `⇡1` `⇣2` | not pushed · not pulled from GitHub |
| ` 1.27.1` | the Go version from `go.mod` |
| `󰡨` | the project has a docker-compose file |
| `⎈ orbstack` | Kubernetes context — only in a k8s project or after `kubectl`/`helm` in this window |
| `✘ 1` | the last command failed (exit code) |
| `󱎫 3s` | how long the last command took (if longer than 2 s) |

After Enter the old prompt collapses to `$ command`, so the history stays clean.

### Smooth cursor

The cursor doesn't jump, it glides to the new place, like in VS Code; long jumps leave a glowing
trail. The color comes from the theme. If the cursor ever disappears: in `~/dotfiles/ghostty/config.ghostty`
comment out `cursor-opacity = 0` and `custom-shader = shaders/cursor_smooth.glsl`.

### Drop-down terminal — `` ctrl+` ``

Slides down from the top **in any app**, on the monitor with the mouse; hides when you click elsewhere.
AeroSpace catches the key and asks Ghostty to show the terminal (`ghostty/quick-terminal.applescript`),
so Ghostty needs no Accessibility permission. On the first press macOS asks once
"Allow AeroSpace to control Ghostty?" — click Allow.

Ghostty always runs in the background: it starts at login, and `cmd+q` closes only its windows.

### Greeting and reminders

Every new window shows a logo and a summary (memory, uptime), a command tip of the day and,
**only when there's a reason**:

```
  󰚰  update hasn't run for 9 days · update
  󰊢  not pushed: pulse ⇡2 · watchdog !3 · pl
```

`⇡` — commits that aren't on GitHub (they'd be lost if the Mac is wiped), `!` — uncommitted files.
To turn reminders off: `export NO_REMINDERS=1` in `~/.zshenv`.

### Conveniences

| Command | What it does |
|---|---|
| `ctrl+r` | search command history (atuin) |
| `ctrl+t` / `alt+c` | find a file / jump to a folder (fzf) |
| `z part-of-path` | jump to a folder you've been in |
| `y` | yazi file manager (quit and you stay in that folder) |
| `c` | clear the screen (prompt to the top) — same as `clear`, one letter |
| `mkcd folder` | create it and cd into it |
| `serve 9000` | serve the current folder over http |
| `weather Moscow` | weather |
| `j file.json` | browse JSON interactively |

---

## 3. Projects and Go

| Command | What it does |
|---|---|
| `p` / `p logs` | jump to a project (with a filter) |
| `pl` | all projects: stack, branch, changes, age |
| `up` | start the dependencies from compose (postgres…) and run the app with `.env` (air, else `go run`) |
| `dcd` | stop the dependencies |
| `got` · `gotw` · `gotv` | tests · rerun on save · verbose |
| `gol` | golangci-lint |
| `vuln` | vulnerabilities: govulncheck + trivy |
| `db` | pgcli into the project database (from `DATABASE_URL` / `.env`) |
| `load` | load test (`load http://localhost:8080/health 10 50`) |
| `pd` | `dot project doctor` — what the project has and what it's missing |

### New project — `gonew`

```bash
gonew myapi        # in ~/dev/myapi
gonew myapi --gh   # + a private GitHub repo and push right away
```

Out of the box: Gin + Postgres, `/health` with a test, graceful shutdown, Dockerfile, compose,
migrations, `make help`, air, golangci-lint, **CI on GitHub** (tests, linter, vulnerabilities, Docker),
a README with a CI badge. Before the first commit the template checks that everything builds and tests pass.

---

## 4. Git

| Command | What it does |
|---|---|
| `gs` · `gd` · `gds` | status · diff · diff of what's staged |
| `gaa` · `gcm "text"` · `gp` | add everything · commit · push |
| `gg` | lazygit — git with a UI |
| `gco` | switch branch (picker with a commit preview) |
| `git undo` | undo the last commit, keep the changes |
| `git amend` | add to the last commit |
| `git wip` / `git unwip` | quickly save everything as a "wip" commit / undo it |
| `git fixup` | a fix for an older commit (picker), squashed on `rebase -i` |
| `git recent` | the last 10 branches |
| `git gone` / `git tidy` | branches deleted on GitHub / delete them locally |

- `git pull` rebases (no extra merge commits), `git push` creates the branch on GitHub by itself —
  plain `git push` is enough even for a new branch.
- **Before every commit gitleaks** looks for passwords and tokens; if it finds one, the commit doesn't go through.
  False alarm: add a `gitleaks:allow` comment on the line.
- In the dotfiles repo itself, **before every push** the checks and tests run, so nothing broken gets out.

---

## 5. Docker and Kubernetes

Docker is **OrbStack**: memory is used only while containers run. If it's off, no problem:
**any `docker` command** (and `up`, and `orbstack`) starts it in ~4 s instead of failing with
"failed to connect to the docker API".

### Container dashboard — `orbstack`

```bash
orbstack                 # live dashboard
orbstack run postgres    # new container from a template — shows the docker run command first
orbstack watch           # live rebuild: save the code and the container rebuilds itself
orbstack help            # every subcommand
```

One screen: a table of containers (● running · ○ stopped · ● created · ● failing) with CPU and
memory refreshing on their own; below, the selected container's log and an event feed (start, stop,
crash, out of memory).

| Key | What it does |
|---|---|
| `↑↓` `j k` · wheel · click | pick a container (click again for actions) |
| `enter` | every action for the container, explained, with the docker command behind it |
| `l` · `s` | follow logs (ctrl+c back) · shell inside (exit back) |
| `r` · `x` · `d` | restart · stop/start · remove (data volumes stay) |
| `i` | inside: image, ports, mounts, networks, env (passwords hidden) |
| `f` · `c` | the Dockerfile (the image layers for a prebuilt image) · the project's compose file |
| `n` | new container: postgres, redis, nginx, mongo, mysql, rabbitmq or any image |
| `t` · `w` | stats for all containers · live rebuild |
| `u` / `U` · `e` / `E` | compose project in this folder: up / down · engine: start / stop |
| `?` · `q` | all keys · quit |

The same without the dashboard: `orbstack ps`, `logs`, `sh`, `restart`, `stop`, `start`, `rm`, `top`, `events`,
`up`, `down`, `images`, `clean`, `on`, `off`, `guide`. Without a container name you pick from a list.

**Live rebuild** (`w` or `orbstack watch`) is `docker compose watch`: Docker watches the code,
rebuilds the image and restarts the container on every save. If the compose file has no
`develop.watch` block, it shows one and asks whether to add it (comments in the file are kept).

How to run containers by hand and what every `docker run` flag means: [docker.md](docker.md)
(or `orbstack guide` right in the terminal).

### Everything else

| Command | What it does |
|---|---|
| `dsh` · `dlogs` | shell into a container · its logs (picker) |
| `dc` · `dcu` · `dcd` · `dcl` | docker compose · up -d · down · logs -f |
| `lzd` | lazydocker |
| `k` | kubectl |
| `kx` / `kn` | switch cluster / namespace |
| `klogs name` | logs of every pod by name (stern) |
| `tf` | OpenTofu (Terraform) |

---

## 6. Mac upkeep

| Command | What it does |
|---|---|
| `update` | weekly: brew, Go tools, Docker junk, tldr pages, icons, rebuilds `orbstack` |
| `dot doctor` | is everything in place: ✓ ok, ! take a look, ✗ broken (each with how to fix it). It also notices settings reset by a macOS upgrade and a forgotten `awake on` |
| `dot doctor --deep` | in depth: versions, extra packages, brew doctor (~20 s) |
| `dot tools` | Go tools and their versions (`dot tools install` installs exactly the pinned ones) |
| `ram` | what's eating memory — by app |
| `lean` | free up memory: a report with background agents · `lean on` quits heavy apps from `~/.config/dotfiles/lean` (OrbStack only with no containers) · `lean off` brings them back |
| `killport 8080` · `port 8080` | free a port (gently first, forcefully after 2 s) · who holds it |
| `fkill` | kill a process (picker) |
| `awake on` / `awake off` | don't sleep with the lid closed (for Claude Code from the phone) / back to normal |

### macOS settings — `macos.sh`

```bash
~/dotfiles/macos.sh              # PLAN: what would change ("now → becomes"), changes nothing
~/dotfiles/macos.sh --yes        # apply
~/dotfiles/macos.sh --yes apps   # only one group
```

Groups: `keyboard` `trackpad` `finder` `saving` `screenshots` `dock` `appearance` `apps` `login` `security` `safari`.
- `apps` — code files (.json, .yaml, .sh, .sql, .env…) open in Zed. macOS asks to confirm each
  extension, so run it at the Mac.
- `login` — Raycast at login.
- `security` — firewall and stealth mode (asks for your password).
- `safari` — full address, status bar, Develop menu, no page preloading. It quits Safari first.
  Safari's settings are sandboxed: the terminal needs Full Disk Access (without it the script says so).

### Safari

The browser is Safari: on 8 GB it's the lightest. Besides `macos.sh safari`:
- **ad blocker** uBlock Origin Lite comes from the App Store through the `Brewfile` (a `mas` line). Enable it once:
  Safari → Settings → Extensions;
- **code font** JetBrains Mono on every site: Settings → Advanced → Style sheet → `~/dotfiles/safari/user.css`;
- **wallpaper** on the start page, Safari's own way: new tab → right-click → Customize Start Page.

Screenshots and screen recordings (`cmd+shift+5`) go to `~/Pictures/Screenshots`.

---

## 7. Zed and GoLand

- **Zed**: the **Dev Night** (dark) and **Dev Day** (light) themes switch with macOS, plus its own
  file icons. Extensions install themselves: Go linter, GitHub Actions, Postgres SQL,
  spell check, Docker, Helm, .http requests. `ctrl-r` — tasks, `f5` — debugging.
- **GoLand**: the same themes — a plugin from the
  [release](https://github.com/van1dalgrr-arch/dotfiles/releases/tag/jetbrains-v1.0.0)
  (Settings → Plugins → ⚙️ → Install Plugin from Disk), or just the code colors as `.icls`
  (Settings → Editor → Color Scheme → ⚙️ → Import Scheme). Details: [jetbrains/README.md](../jetbrains/README.md).

---

## 8. A new Mac

One command in Terminal, and everything is as it is now:

```bash
curl -fsSL https://raw.githubusercontent.com/van1dalgrr-arch/dotfiles/main/bootstrap.sh | bash
```

What's left to do by hand (accounts, projects, permissions): [recovery.md](recovery.md).
Your wallpaper photos come from the private copy: `gh repo clone dotfiles-photos ~/dotfiles/wallpapers/photos`.

---

## 9. If something's wrong

1. `dot doctor` finds it and tells you how to fix it.
2. [troubleshooting.md](troubleshooting.md) — common problems (icons reset, the theme didn't apply,
   the drop-down terminal doesn't open, `orbstack` won't start…).
3. Ask Claude 🙂
