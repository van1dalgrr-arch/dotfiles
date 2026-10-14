# If the Mac was wiped

🇷🇺 [Русская версия](recovery.ru.md) · [all docs](README.md)

Almost everything comes back with one command from this repo. What's left by hand: signing in to accounts,
installing apps that aren't in the Brewfile, and cloning projects. Anything that wasn't pushed is gone.

## Restore (~1 hour, mostly waiting for downloads)

1. One command in Terminal — Xcode tools, Homebrew, dotfiles and every program:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/van1dalgrr-arch/dotfiles/main/bootstrap.sh | bash
   ```
   (macOS shows the Xcode tools installer — click Install; Homebrew asks for your password)
2. macOS settings: `~/dotfiles/macos.sh` (plan) → `./macos.sh --yes`, then log out and back in
3. Open Ghostty → `dot doctor`. Everything should be ✓; every ✗ says how to fix it

Optional: `make devops` (kind, OpenTofu, tflint…).

## What comes back by itself

| What | From |
|---|---|
| Programs: Ghostty, OrbStack, AeroSpace, Raycast, Yaak, TablePlus, Zed, VS Code, every CLI | `Brewfile` |
| The uBlock Origin Lite ad blocker for Safari | `Brewfile` (a `mas` line, from the App Store) |
| `orbstack`, the container dashboard | `install.sh` builds it from `berth/` |
| Configs: zsh, prompt, git, Ghostty, AeroSpace, Zed, VS Code, btop, lazygit… | `install.sh` (symlinks) |
| Theme, wallpaper, app and folder icons | `theme vesper`, `wall eclipse` (drawn from the Swift files) |
| The Zed Dev Night / Dev Day themes and icons | `zed/dev-night-theme`, `zed/dev-night-icons` |
| gopls, air, govulncheck, gofumpt at the same versions | `go/tools.txt` |
| VS Code extensions | `vscode/extensions.txt` |
| Keyboard, Finder, Dock, screenshots, firewall, Safari | `macos.sh` |

## By hand

- [ ] GitHub: `gh auth login` (HTTPS sign-in through the browser, no SSH keys)
- [ ] Projects: `mkdir ~/dev && cd ~/dev && gh repo clone <name>` for each (`gh repo list` shows all of yours)
- [ ] Wallpaper photos: `gh repo clone dotfiles-photos ~/dotfiles/wallpapers/photos`
- [ ] Sign in: Telegram, Discord, Yandex Music, Claude, ChatGPT
- [ ] VPN (Happ): add the configs again
- [ ] Safari: Settings → Extensions → enable uBlock Origin Lite; Advanced → Style sheet → `~/dotfiles/safari/user.css`
- [ ] `./macos.sh --yes safari` — the terminal needs Full Disk Access for a moment; take it back afterwards
- [ ] Raycast: import the settings if you saved an export (Settings → Advanced → Export)
- [ ] Zed: sign in (for AI)
- [ ] Privacy & Security permissions: AeroSpace and Ghostty → Accessibility (without it the hotkeys and the drop-down terminal don't work)

## Apps not in the Brewfile

Installed from websites, the App Store or a brew command that skipped the `Brewfile`; `dot doctor --deep` lists them as "not in Brewfile":
Telegram, Discord, Yandex Music, Happ, ChatGPT, Claude, GitHub Desktop, JetBrains Toolbox, UTM, Rectangle, Hammerspoon.
Anything you always need is better added to the `Brewfile` (`cask "telegram"` and so on) — then it comes back by itself too.

## What's lost

| What | How not to lose it |
|---|---|
| Uncommitted and unpushed work in projects | `pl` — a project with `!N` (changes) or `⇡N` (not pushed) → commit and push |
| Branches without an upstream (local only) | `git push -u origin <branch>` |
| Databases in OrbStack containers (Docker volumes) | for study projects it doesn't matter, migrations rebuild them; anything important — `pg_dump` |
| Command history (atuin), zoxide jumps | not critical, they build up again |
| Everything else in the home folder (downloads, documents) | Time Machine or iCloud Drive |

## From `dot backup`

`dot backup` (weekly — the greeting reminds you) puts what isn't on GitHub into the private `dotfiles-backup` repo:
unpushed commits of every project in `~/dev`, uncommitted changes, a system snapshot and the dotfiles state.

```bash
gh repo clone dotfiles-backup ~/backup
cat ~/backup/system/brew-casks.txt ~/backup/system/apps.txt     # what was installed
# a project: clone it from GitHub first, then bring your work back
cd ~/dev/kinozaBack/kinoza-back
git fetch ~/backup/repos/kinozaBack/kinoza-back/unpushed.bundle 'refs/heads/*:refs/remotes/backup/*'   # unpushed commits
git apply ~/backup/repos/kinozaBack/kinoza-back/uncommitted.patch                                      # uncommitted changes
```

New files (`untracked.txt`) aren't in the backup — only their names: they tend to be `.env` files and keys.

## How not to lose things next time

- **`dot backup`** weekly: unpushed work and a system snapshot into a private repo (see above).
- **Time Machine** on an external disk: built into macOS, saves absolutely everything, costs no memory.
  `dot doctor` reminds you while there are no backups.
- Before leaving a project — `pl`: if anything shows `!` or `⇡`, push it.
- A new program → a `Brewfile` line right away; a new config → into the repo + a `link` in `install.sh`.
- A macOS upgrade (27 and later) erases none of this — restoring is only needed after the disk is wiped.
